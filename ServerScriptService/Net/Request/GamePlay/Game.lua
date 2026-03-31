local ConditionUtil = require(game.ReplicatedStorage.ScriptAlias.ConditionUtil)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local RunnerGameHandler = require(game.ServerScriptService.ScriptAlias.RunnerGameHandler)
local TeleportManager = require(game.ServerScriptService.ScriptAlias.TeleportManager)

local Game = {}

-- Game

function Game:Enter(player, param)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	local result = RunnerGameHandler:PlayerEnter(player)
	return result
end

function Game:Leave(player, param)
	local result = RunnerGameHandler:PlayerLeave(player)
	return result
end

function Game:GetPhase(player)
	return RunnerGameHandler:GetPhase()
end

function Game:CheckCondition(player, param)
	local checkerType = param.Type
	local requireValue = param.RequireValue
	local param = param.Param
	local result = ConditionUtil:GetCheckInfo(player, checkerType, requireValue, param)
	return result
end

-- Teleport

function Game:Teleport(player, param)
	local placeID = param.PlaceID
	local result = TeleportManager:Teleport(player, placeID)
	return result
end

return Game
