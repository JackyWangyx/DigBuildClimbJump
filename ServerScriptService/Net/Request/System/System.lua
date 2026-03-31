local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)

local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)
local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local PlayerProperty = require(game.ServerScriptService.ScriptAlias.PlayerProperty)

local System = {}

function LoadInfo(player)
	local saveInfo = PlayerPrefs:GetModule(player, "System")
	return saveInfo
end

function System:DispatchEvent(player, param)
	local event = param.EventName
	local eventParam = param.EventParam
	eventParam.Player = player
	EventManager:Dispatch(event, eventParam)
end

return System