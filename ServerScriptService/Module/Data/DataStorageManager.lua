local DataStoreService = game:GetService("DataStoreService")

local TaskThrottleScheduler = require(game.ReplicatedStorage.ScriptAlias.TaskThrottleScheduler)
local LogUtil = require(game.ReplicatedStorage.ScriptAlias.LogUtil)

local DataStorageManager = {}

DataStorageManager.RequestType = {
	Get = 1,
	Set = 2,
	Update = 3,
}

DataStorageManager.PriorityType = {
	NotImprotant = -100,
	Normal = 0,
	Important = 50,
	VeryImportant = 100,
}

local Cache = {}

local MergeCallbackMap = {
	[DataStorageManager.RequestType.Get] = {},
	[DataStorageManager.RequestType.Set] = {},
	[DataStorageManager.RequestType.Update] = {}
}

local GetTask = TaskThrottleScheduler.new(15, 0.5, 5, 1.1)
local SetTask = TaskThrottleScheduler.new(15, 0.75, 5, 1.1)
local UpdateTask = TaskThrottleScheduler.new(15, 1, 5, 1.1)

function DataStorageManager:Init()
	-- 队列未完成时延迟关闭服务器，最多半分钟
	game:BindToClose(function()
		local timeout = 30
		local start = tick()
		
		local remainTaskCount = DataStorageManager:GetRequestQueueCount()
		if remainTaskCount > 0 then
			LogUtil:Log("[DataStorage] Remain Request ", tostring(remainTaskCount))
			while (DataStorageManager:GetRequestQueueCount() > 0) and (tick() - start < timeout) do
				task.wait(0.5)
			end

			LogUtil:Log("[DataStorage] Remain Request Complete")
		end	
	end)
end

function DataStorageManager:GetRequestQueueCount()
	local c1 = GetTask:GetCount()
	local c2 = SetTask:GetCount()
	local c3 = UpdateTask:GetCount()
	return c1 + c2 + c3
end

-- 安全获取或创建缓存
local function GetDataStoreCache(dataStoreKey)
	local cache = Cache[dataStoreKey]
	if not cache then
		local success, store = pcall(function()
			return DataStoreService:GetDataStore(dataStoreKey)
		end)

		if not success then
			error("[DataStorage] Failed to get DataStore: ", debug.traceback(store, 2))
		end
		
		cache = {
			DataStore = store,
			Data = {},
		}
		
		Cache[dataStoreKey] = cache
	end
	return cache
end

local function GetRequestKey(dataStoreKey, key)
	local requestKey = dataStoreKey..":"..key
	return requestKey
end

local function CreateTask(request)
	local requestKey = request.RequestKey
	local type = request.Type
	local func = request.Func
	local priority = request.Priority
	if type == DataStorageManager.RequestType.Get then
		GetTask:AddOrReplaceTask(requestKey, func, priority)
	elseif type == DataStorageManager.RequestType.Set then
		SetTask:AddOrReplaceTask(requestKey, func, priority)
	elseif type == DataStorageManager.RequestType.Update then
		UpdateTask:AddOrReplaceTask(requestKey, func, priority)
	end
end

-- 加载数据（内部）
local function GetImpl(dataStoreKey, key, callback)
	local cache = GetDataStoreCache(dataStoreKey)
	local success, result = pcall(function()
		DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.SetIncrementAsync)
		return cache.DataStore:GetAsync(key)
	end)

	if success then
		cache.Data[key] = result or {}
		if callback then callback(true, cache.Data[key]) end
	else
		warn("[DataStorage] Failed to load key:", key, debug.traceback(result, 2))
		if callback then callback(false, nil) end
	end	
end

-- 设置数据 并发覆盖
local function SetImpl(dataStoreKey, key, callback)
	local cache = GetDataStoreCache(dataStoreKey)
	local value = cache.Data[key]
	local success, result = pcall(function()
		if value == nil then
			return cache.DataStore:RemoveAsync(key)
		else
			return cache.DataStore:SetAsync(key, value)
		end
	end)

	if not success then
		warn("[DataStorage] Failed to set key:", key, debug.traceback(result, 2))
	end

	if callback then
		callback(success, value)
	end
end

-- 更新数据 原子操作
local function UpdateImpl(dataStoreKey, key, callback)
	local cache = GetDataStoreCache(dataStoreKey)
	local value = cache.Data[key]
	local success, result = pcall(function()
		if value == nil then
			return cache.DataStore:RemoveAsync(key)
		else
			return cache.DataStore:UpdateAsync(key, function(oldValue)
				return value
			end)	
		end
	end)

	if not success then
		warn("[DataStorage] Failed to update key:", key, debug.traceback(result, 2))
	end

	if callback then
		callback(success, value)
	end
end

-- 清除缓存
function DataStorageManager:ClearCache(dataStoreKey, key)
	local cache = GetDataStoreCache(dataStoreKey)
	if cache and cache.Data then
		cache.Data[key] = nil
	end
end

-- 清除并持久化
function DataStorageManager:Clear(dataStoreKey, key)
	local cache = GetDataStoreCache(dataStoreKey)
	if cache and cache.Data then
		cache.Data[key] = nil
		self:SetAsync(dataStoreKey, key)
	end
end

-- 通用回调合并
local function CreateMergedRequest(opType, dataStoreKey, key, funcImpl, callback, priority)
	local requestKey = GetRequestKey(dataStoreKey, key)
	local callbackList = MergeCallbackMap[opType][requestKey]

	if not callbackList then
		callbackList = {}
		MergeCallbackMap[opType][requestKey] = callbackList
	end
	
	-- 回调列表非空，则说明还有未执行完的相同请求，则直接合并，统一处理
	local callbackCount = #callbackList
	table.insert(callbackList, callback)

	-- 第一次请求才真正加入调度器
	if callbackCount == 0 then
		local request = {
			RequestKey = requestKey,
			DataStoreKey = dataStoreKey,
			Key = key,
			Type = opType,
			Func = function()
				local function safeRun()
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
					if not ok then
						warn("[DataStorage] Task error for key:", requestKey, debug.traceback(err, 2))
					end
				end

				safeRun()
				MergeCallbackMap[opType][requestKey] = nil
			end,
			Priority = priority or DataStorageManager.PriorityType.Normal,
			Timestamp = tick(),
		}

		CreateTask(request)
	end
end

-- 同步加载
function DataStorageManager:GetSync(dataStoreKey, key, priority)
	local cache = GetDataStoreCache(dataStoreKey)
	local isWorking = true
	local result = {}
	DataStorageManager:GetAsync(dataStoreKey, key, function(success, data)
		isWorking = false
		result.Success = success
		result.Data = data
	end, priority)
	while isWorking do
		task.wait()
	end

	return result
end

-- 异步加载
function DataStorageManager:GetAsync(dataStoreKey, key, callback, priority)
	local cache = GetDataStoreCache(dataStoreKey)
	if cache.Data[key] then
		if callback then callback(true, cache.Data[key]) end
		return
	end

	CreateMergedRequest(
		DataStorageManager.RequestType.Get,
		dataStoreKey,
		key,
		function(onDone)
			GetImpl(dataStoreKey, key, onDone)
		end,
		callback,
		priority
	)
end

-- 异步设置
function DataStorageManager:SetAsync(dataStoreKey, key, callback, priority)
	CreateMergedRequest(
		DataStorageManager.RequestType.Set,
		dataStoreKey,
		key,
		function(onDone)
			SetImpl(dataStoreKey, key, onDone)
		end,
		callback,
		priority
	)
end

-- 异步更新
function DataStorageManager:UpdateAsync(dataStoreKey, key, callback, priority)
	CreateMergedRequest(
		DataStorageManager.RequestType.Update,
		dataStoreKey,
		key,
		function(onDone)
			UpdateImpl(dataStoreKey, key, onDone)
		end,
		callback,
		priority
	)
end


return DataStorageManager
