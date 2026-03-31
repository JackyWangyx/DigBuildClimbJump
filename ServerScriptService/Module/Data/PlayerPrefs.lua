local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local LogUtil = require(game.ReplicatedStorage.ScriptAlias.LogUtil)

local DataStorageManager = require(game.ServerScriptService.ScriptAlias.DataStorageManager)
local DataUpgradeManager = require(game.ServerScriptService.ScriptAlias.DataUpgradeManager)

local Define = require(game.ReplicatedStorage.Define)

local PlayerPrefs = {}

local DATA_STORE_NAME = "PlayerSaveData"
local VERSION_CODE = "v1"

local AutoSaveCheckInterval = 15

local SaveInfoCache = {}
local SaveInfoLoadState = {}

function PlayerPrefs:Init()
	PlayerManager:HandlePlayerAddRemove(function(player)
		PlayerPrefs:SetPlayerSaveInfoState(player, false)
		PlayerPrefs:LoadFromDataStore(player)
		--LogUtil:Log("[PlayerPrefs] Load PlayerPrefs : ",player.UserId)
	end, function(player)
		local playerKey = PlayerPrefs:GetPlayerKey(player)
		local playerId = player.UserId
		
		task.defer(function()
			PlayerPrefs:SaveToDataStore(player, function()
				if not PlayerManager:IsPlayerInServerById(playerId) then
					PlayerPrefs:ClearPlayerCacheByKey(playerKey)
				end

				PlayerPrefs:SetPlayerSaveInfoState(player, nil)
			end)
		end)		
	end, false)
	
	game:BindToClose(function()
		for _, player in ipairs(game.Players:GetPlayers()) do
			PlayerPrefs:SaveToDataStore(player)
		end
	end)
	
	PlayerPrefs:AutoSaveTask()
end

function PlayerPrefs:AutoSaveTask()
	task.spawn(function()
		while task.wait(AutoSaveCheckInterval) do
			local currentTime = os.time()
			for _, player in ipairs(game.Players:GetPlayers()) do
				local saveInfo = PlayerPrefs:GetPlayerSaveInfo(player)
				if saveInfo then
					local lastSave = saveInfo.LastSaveTime or 0
					if currentTime - lastSave >= Define.Data.PlayerAutoSaveInterval then
						LogUtil:Log("[PlayerPrefs] Auto Saving : ", player.UserId)
						PlayerPrefs:SaveToDataStore(player)
					end
				end
			end
		end
	end)
end

function PlayerPrefs:GetCache()
	return SaveInfoCache
end

function PlayerPrefs:ClearPlayerCacheByKey(playerKey)
	SaveInfoCache[playerKey] = nil
	DataStorageManager:ClearCache(DATA_STORE_NAME, playerKey)
end

-- 获取玩家 Key
function PlayerPrefs:GetPlayerKey(player)
	local key = "PlayerSaveData_" .. player.UserId
	return key
end

-- 获取指定玩家的所有数据
function PlayerPrefs:GetPlayerSaveInfo(player)
	local playerKey = PlayerPrefs:GetPlayerKey(player)
	if not PlayerPrefs:GetPlayerSaveInfoState(player) then
		PlayerPrefs:LoadFromDataStore(player)
		PlayerPrefs:WaitForPlayerSaveLoaded(player)
	end
	
	local saveInfo = SaveInfoCache[playerKey]
	return saveInfo
end

-- SaveInfo State
function PlayerPrefs:SetPlayerSaveInfoState(player, state)
	if not player then return end
	local key = player.UserId
	SaveInfoLoadState[key] = state
end

function PlayerPrefs:GetPlayerSaveInfoState(player)
	if not player then return false end
	local key = player.UserId
	local state = SaveInfoLoadState[key]
	if state == nil then return false end
	return state
end

function PlayerPrefs:WaitForPlayerSaveLoaded(player)
	while true do
		local check = PlayerPrefs:GetPlayerSaveInfoState(player)
		if check then
			break
		end
		
		task.wait(0.1)
	end
end

-- 获取指定玩家的指定模块数据
function PlayerPrefs:GetModule(player, moduleKey)
	local playerKey = PlayerPrefs:GetPlayerKey(player)
	local saveInfo = PlayerPrefs:GetPlayerSaveInfo(player)
	local moduleInfo = saveInfo[moduleKey]
	if not moduleInfo then
		moduleInfo = {}
		saveInfo[moduleKey] = moduleInfo
	end
	return moduleInfo
end

function PlayerPrefs:SetModule(player, moduleKey, moduleInfo)
	local playerKey = PlayerPrefs:GetPlayerKey(player)
	local saveInfo = PlayerPrefs:GetPlayerSaveInfo(player)
	if not moduleInfo then
		moduleInfo = {}
	end
	
	saveInfo[moduleKey] = moduleInfo
end

-- 获取值
function PlayerPrefs:GetValue(player, moduleKey, valueKey)
	local playerKey = PlayerPrefs:GetPlayerKey(player)
	local moduleInfo = PlayerPrefs:GetModule(player, moduleKey)
	local value = moduleInfo[valueKey]
	return value
end

-- 设置值
function PlayerPrefs:SetValue(player, moduleKey, valueKey, value)
	local playerKey = PlayerPrefs:GetPlayerKey(player)
	local moduleInfo = PlayerPrefs:GetModule(player, moduleKey)
	moduleInfo[valueKey] = value
end

function PlayerPrefs:LoadFromDataStore(player)
	local playerKey = PlayerPrefs:GetPlayerKey(player)
	DataStorageManager:GetAsync(DATA_STORE_NAME, playerKey, function(success, saveInfo)
		if success then
			SaveInfoCache[playerKey] = saveInfo
			if saveInfo then
				if not saveInfo.VersionCode then
					saveInfo.VersionCode = VERSION_CODE
				end
				
				saveInfo.LastSaveTime = os.time()
			end
			
			DataUpgradeManager:CheckUpgradePlayer(saveInfo, VERSION_CODE)
			PlayerPrefs:SetPlayerSaveInfoState(player, true)
			--LogUtil:Log("[PlayerPrefs] Load PlayerPrefs : ", player.UserId)
		end
	end, DataStorageManager.PriorityType.VeryImportant)
end

function PlayerPrefs:SaveToDataStore(player, onDone)
	-- 忽略未加载成功存档的玩家保存请求，防止空档覆盖
	if not PlayerPrefs:GetPlayerSaveInfoState(player) then 
		return 
	end
	
	local playerKey = PlayerPrefs:GetPlayerKey(player)
	local saveInfo = PlayerPrefs:GetPlayerSaveInfo(player)
	if saveInfo then
		saveInfo.LastSaveTime = os.time()
	end
	
	DataStorageManager:SetAsync(DATA_STORE_NAME, playerKey, function(success)
		if success then
			--LogUtil:Log("[PlayerPrefs] Save ", player.UserId, success)
			if onDone then
				onDone()
			end
		end
	end, DataStorageManager.PriorityType.VeryImportant)	
end

function PlayerPrefs:ClearPlayer(player)
	local playerKey = PlayerPrefs:GetPlayerKey(player)
	SaveInfoCache[playerKey] = {}	
	DataStorageManager:Clear(DATA_STORE_NAME, playerKey)
end

return PlayerPrefs
