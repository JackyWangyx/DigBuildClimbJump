local MemoryStoreService = game:GetService("MemoryStoreService")

local TaskThrottleScheduler = require(game.ReplicatedStorage.ScriptAlias.TaskThrottleScheduler)

local MemoryStorageManager = {}

local Cache = {}

local MergeCallbackMap = {
	[1] = {}, -- Get
	[2] = {}, -- Set
	[3] = {}, -- Update
	[4] = {}, -- Remove
}

MemoryStorageManager.RequestType = {
	Get = 1,
	Set = 2,
	Update = 3,
	Remove = 4,
}

MemoryStorageManager.PriorityType = {
	NotImportant = -100,
	Normal = 0,
	Important = 50,
	VeryImportant = 100,
}

-- MemoryStore 节奏比 DataStore 更快，可以设小点
local GetTask = TaskThrottleScheduler.new(50, 0.1, 5, 1.05)
local SetTask = TaskThrottleScheduler.new(50, 0.1, 5, 1.05)
local UpdateTask = TaskThrottleScheduler.new(50, 0.1, 5, 1.05)
local RemoveTask = TaskThrottleScheduler.new(50, 0.1, 5, 1.05)

function MemoryStorageManager:Init()
	game:BindToClose(function()
		local timeout = 15
		local start = tick()
		local remainTaskCount = MemoryStorageManager:GetRequestQueueCount()
		if remainTaskCount > 0 then
			print("[MemoryStorage] Remain Request "..tostring(remainTaskCount))
			while (MemoryStorageManager:GetRequestQueueCount() > 0) and (tick() - start < timeout) do
				task.wait(0.5)
			end

			print("[MemoryStorage] Remain Request Complete")
		end	
	end)
end

function MemoryStorageManager:GetRequestQueueCount()
	return GetTask:GetCount() + SetTask:GetCount() + UpdateTask:GetCount() + RemoveTask:GetCount()
end

-- 安全获取或创建缓存
local function GetMemoryStoreCache(mapName)
	local cache = Cache[mapName]
	if not cache then
		local success, store = pcall(function()
			return MemoryStoreService:GetHashMap(mapName)
		end)
		if not success then
			error("[MemoryStorage] Failed to get HashMap: ", debug.traceback(store, 2))
		end
		cache = {
			Map = store,
			Data = {}
		}
		Cache[mapName] = cache
	end
	return cache
end

local function GetRequestKey(mapName, key)
	return mapName .. ":" .. key
end

local function CreateRequest(request)
	local type = request.Type
	if type == MemoryStorageManager.RequestType.Get then
		GetTask:AddOrReplaceTask(request.RequestKey, request.Func, request.Priority)
	elseif type == MemoryStorageManager.RequestType.Set then
		SetTask:AddOrReplaceTask(request.RequestKey, request.Func, request.Priority)
	elseif type == MemoryStorageManager.RequestType.Update then
		UpdateTask:AddOrReplaceTask(request.RequestKey, request.Func, request.Priority)
	elseif type == MemoryStorageManager.RequestType.Remove then
		RemoveTask:AddOrReplaceTask(request.RequestKey, request.Func, request.Priority)
	end
end

-- 实现函数
local function GetImpl(mapName, key, onDone)
	local cache = GetMemoryStoreCache(mapName)
	local success, value = pcall(function()
		return cache.Map:GetAsync(key)
	end)
	if success then
		cache.Data[key] = value
		onDone(true, value)
	else
		warn("[MemoryStorage] Failed to get key:", key, value)
		onDone(false, nil)
	end
end

local function SetImpl(mapName, key, expiration, onDone)
	local cache = GetMemoryStoreCache(mapName)
	local value = cache.Data[key]
	local success, err = pcall(function()
		cache.Map:SetAsync(key, value, expiration or 60)
	end)
	if not success then
		warn("[MemoryStorage] Failed to set key:", key, err)
	end
	onDone(success, value)
end

local function UpdateImpl(mapName, key, expiration, onDone)
	local cache = GetMemoryStoreCache(mapName)
	local value = cache.Data[key]
	local success, err = pcall(function()
		cache.Map:UpdateAsync(key, function()
			return value
		end, expiration or 60)
	end)
	if not success then
		warn("[MemoryStorage] Failed to update key:", key, err)
	end
	onDone(success, value)
end

local function RemoveImpl(mapName, key, onDone)
	local cache = GetMemoryStoreCache(mapName)
	cache.Data[key] = nil
	local success, err = pcall(function()
		cache.Map:RemoveAsync(key)
	end)
	if not success then
		warn("[MemoryStorage] Failed to remove key:", key, err)
	end
	onDone(success, nil)
end

-- 回调合并
local function CreateMergedRequest(opType, mapName, key, funcImpl, callback, priority)
	local requestKey = GetRequestKey(mapName, key)
	local callbackList = MergeCallbackMap[opType][requestKey]

	if not callbackList then
		callbackList = {}
		MergeCallbackMap[opType][requestKey] = callbackList
	end

	local callbackCount = #callbackList
	table.insert(callbackList, callback)

	if callbackCount == 0 then
		local request = {
			RequestKey = requestKey,
			Type = opType,
			Func = function()
				local function cleanup()
					MergeCallbackMap[opType][requestKey] = nil
				end
				local ok, err = pcall(function()
					funcImpl(function(success, value)
						local list = MergeCallbackMap[opType][requestKey]
						if list then
							for _, cb in ipairs(list) do
								if cb then
									pcall(cb, success, value)
								end
							end
						end
					end)
				end)
				cleanup()
				if not ok then
					warn("[MemoryStorage] Request error:", err)
				end
			end,
			Priority = priority or MemoryStorageManager.PriorityType.Normal,
			Timestamp = tick(),
		}
		CreateRequest(request)
	end
end

-- API
function MemoryStorageManager:GetAsync(mapName, key, callback, priority)
	local cache = GetMemoryStoreCache(mapName)
	if cache.Data[key] ~= nil then
		if callback then callback(true, cache.Data[key]) end
		return
	end
	CreateMergedRequest(MemoryStorageManager.RequestType.Get, mapName, key, function(onDone)
		GetImpl(mapName, key, onDone)
	end, callback, priority)
end

function MemoryStorageManager:SetAsync(mapName, key, value, expiration, callback, priority)
	local cache = GetMemoryStoreCache(mapName)
	cache.Data[key] = value
	CreateMergedRequest(MemoryStorageManager.RequestType.Set, mapName, key, function(onDone)
		SetImpl(mapName, key, expiration, onDone)
	end, callback, priority)
end

function MemoryStorageManager:UpdateAsync(mapName, key, value, expiration, callback, priority)
	local cache = GetMemoryStoreCache(mapName)
	cache.Data[key] = value
	CreateMergedRequest(MemoryStorageManager.RequestType.Update, mapName, key, function(onDone)
		UpdateImpl(mapName, key, expiration, onDone)
	end, callback, priority)
end

function MemoryStorageManager:RemoveAsync(mapName, key, callback, priority)
	CreateMergedRequest(MemoryStorageManager.RequestType.Remove, mapName, key, function(onDone)
		RemoveImpl(mapName, key, onDone)
	end, callback, priority)
end

function MemoryStorageManager:ClearCache(mapName, key)
	local cache = GetMemoryStoreCache(mapName)
	cache.Data[key] = nil
end

return MemoryStorageManager
