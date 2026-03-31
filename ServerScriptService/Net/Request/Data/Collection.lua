local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)

local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)
local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)

local Define = require(game.ReplicatedStorage.Define)

local Collection = {}

local DataTemplate = {
	Collection = {
		Pet = {
			["ID"] = true,
		},
		Tool = {},
	}
}

function Collection:Init()
	EventManager:Listen(EventManager.Define.GetPet, function(param)
		local player = param.Player
		param.Type = "Pet"
		Collection:Unlock(player, param)
	end)
	
	EventManager:Listen(EventManager.Define.GetTool, function(param)
		local player = param.Player
		param.Type = "Tool"
		Collection:Unlock(player, param)
	end)
end

function LoadInfo(player)
	local saveInfo = PlayerPrefs:GetModule(player, "Collection")
	return saveInfo
end

function Collection:GetInfoList(player, param)
	local collectType = param.Type
	local saveInfo = LoadInfo(player)
	local infoList = saveInfo[collectType]
	if not infoList then
		infoList = {}
		saveInfo[collectType] = infoList
	end
	
	return infoList
end

function Collection:GetUnlock(player, param)
	local collectType = param.Type
	local id = param.ID
	local infoList = Collection:GetInfoList(player, param)
	local unlock = infoList[tostring(id)]
	if unlock == true then
		return true
	else
		return false
	end
end

function Collection:Unlock(player, param)
	local collectType = param.Type
	local id = param.ID
	local infoList = Collection:GetInfoList(player, param)
	infoList[tostring(id)] = true
	return true
end

function Collection:GetDataList(player, param)
	local collectType = param.Type
	local dataList = ConfigManager:GetDataList(collectType)
	local infoList = Collection:GetInfoList(player, param)
	local resultList = {}
	for _, data in ipairs(dataList) do
		if data.Indexable then
			local unLock = infoList[tostring(data.ID)]
			local resultData = Util:TableCopy(data)
			if unLock == true then
				resultData.Indexed = true
			else
				resultData.Indexed = false
			end
			
			table.insert(resultList, resultData)
		end
	end
	
	return resultList
end

return Collection
