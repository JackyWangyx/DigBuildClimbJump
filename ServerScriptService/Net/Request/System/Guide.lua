local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)

local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)
local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local PlayerProperty = require(game.ServerScriptService.ScriptAlias.PlayerProperty)

local GuideDefine = require(game.ReplicatedStorage.ScriptAlias.GuideDefine)

local Guide = {}

function LoadInfo(player)
	local saveInfo = PlayerPrefs:GetModule(player, "Guide")
	return saveInfo
end

function Guide:GetInfo(player, param)
	local key = param.Key
	local infoList = Guide:GetInfoList(player)
	local guideInfo = infoList[key]
	return guideInfo
end

function Guide:GetInfoList(player)
	local saveInfo = LoadInfo(player)
	if not saveInfo.GuideList then
		saveInfo.GuideList = {}
	end
	
	for index, guideConfig in ipairs(GuideDefine.GuideList) do
		local key = guideConfig.Key
		local guideInfo = saveInfo.GuideList[key] 
		if not guideInfo then
			guideInfo = {
				IsComplete = false,
			}

			saveInfo.GuideList[key] = guideInfo
		end
	end
	
	return saveInfo.GuideList
end

function Guide:CheckComplete(player, param)
	local key = param.Key
	local info = Guide:GetInfo(player, param)
	return info.IsComplete
end

function Guide:Complete(player, param)
	local key = param.Key
	local info = Guide:GetInfo(player, param)
	if info.IsComplete then
		return false
	end
	
	info.IsComplete = true
	return true
end

return Guide