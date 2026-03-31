local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local LogUtil = require(game.ReplicatedStorage.ScriptAlias.LogUtil)

local DataStorageManager = require(game.ServerScriptService.ScriptAlias.DataStorageManager)
local DataUpgradeManager = require(game.ServerScriptService.ScriptAlias.DataUpgradeManager)

local ServerPrefs = {}

local VERSION_CODE = "v1"

local SaveDataCache = {}

function ServerPrefs:Init()
	-- 防止关闭服务器时抢占玩家保存时间，服务器数据在运行过程中，由使用模块主动调用保存请求
	
	--game:BindToClose(function()
	--	for dataStoreKey, moduleValue in pairs(SaveDataCache) do
	--		for moduleKey, saveInfo in pairs(moduleValue) do
	--			ServerPrefs:SaveToDataStore(dataStoreKey, moduleKey, function(success)
	--				print("[Server] Save ServerPrefs "..tostring(success))
	--			end)
	--		end		
	--	end
	--end)
end

function ServerPrefs:Clear()
	SaveDataCache = {}
end

function ServerPrefs:GetCache()
	return SaveDataCache
end

function ServerPrefs:ClearInternal()
	for dataStoreKey, module in pairs(SaveDataCache) do
		for moduleKey, saveInfo in pairs(module) do
			DataStorageManager:ClearCache(dataStoreKey, moduleKey)
			ServerPrefs:SaveToDataStore(dataStoreKey, moduleKey, function(success)
				LogUtil:Log("[Server] Save ServerPrefs ",dataStoreKey, moduleKey, success)
			end)
		end		
	end
end

function ServerPrefs:ClearModuleCache(dataStoreKey, moduleKey)
	local dataStoreCache = SaveDataCache[dataStoreKey]
	if dataStoreCache then
		dataStoreCache[moduleKey] = nil
	end
	
	DataStorageManager:ClearCache(dataStoreKey, moduleKey)
end

function ServerPrefs:GetDataStoreModuleCache(dataStoreKey, moduleKey)
	local dataStoreCache = SaveDataCache[dataStoreKey]
	if dataStoreCache then
		local result = dataStoreCache[moduleKey]
		if result then return result end
	end
	
	local result = ServerPrefs:LoadFromDataStore(dataStoreKey, moduleKey)	
	return SaveDataCache[dataStoreKey][moduleKey]
end

function ServerPrefs:GetModule(dataStoreKey, moduleKey)
	local module = ServerPrefs:GetDataStoreModuleCache(dataStoreKey, moduleKey)
	return module
end

function ServerPrefs:SetModule(dataStoreKey, moduleKey, moduleValue)
	local module = ServerPrefs:GetDataStoreModuleCache(dataStoreKey, moduleKey)
	module[moduleKey] = moduleValue
end

function ServerPrefs:GetValue(dataStoreKey, moduleKey, valueKey)
	local module = ServerPrefs:GetModule(dataStoreKey, moduleKey)
	local result = module[valueKey]
	return result
end

function ServerPrefs:SetValue(dataStoreKey, moduleKey, valueKey, value)
	local module = ServerPrefs:GetModule(dataStoreKey, moduleKey)
	module[valueKey] = value
end

function ServerPrefs:LoadFromDataStore(dataStoreKey, moduleKey)
	local result = DataStorageManager:GetSync(dataStoreKey, moduleKey, DataStorageManager.PriorityType.Important)
	local dataStoreCache = SaveDataCache[dataStoreKey]
	if not dataStoreCache then
		dataStoreCache = {}
		SaveDataCache[dataStoreKey] = dataStoreCache
	end

	if result.Success then
		local moduleValue = result.Data
		dataStoreCache[moduleKey] = moduleValue
		if dataStoreCache[moduleKey] and not dataStoreCache[moduleKey].VersionCode then
			dataStoreCache[moduleKey].VersionCode = VERSION_CODE
		end

		DataUpgradeManager:CheckUpgradeServer(moduleValue, VERSION_CODE)
		--LogUtil:Log("[ServerPrefs] Load ServerPrefs "..dataStoreKey.." / "..moduleKey.." Success")
	else
		LogUtil:Warn("[ServerPrefs] Load ServerPrefs "..dataStoreKey.." / "..moduleKey.." Fail")
	end
	
	return result
end

function ServerPrefs:SaveToDataStore(dataStoreKey, moduleKey, callback)
	DataStorageManager:SetAsync(dataStoreKey, moduleKey, callback)
end

return ServerPrefs