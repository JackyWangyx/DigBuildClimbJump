local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)
local PlayerStatus = require(game.ServerScriptService.ScriptAlias.PlayerStatus)

local RunnerGameHandler = require(game.ServerScriptService.ScriptAlias.RunnerGameHandler)
local RunnerGameSlotManager = require(game.ServerScriptService.ScriptAlias.RunnerGameSlotManager)
local RunnerGameLoopManager = require(game.ServerScriptService.ScriptAlias.RunnerGameLoopManager)

local Game = {}

Game.Icon = "🎲"
Game.Color = Color3.new(0.941176, 0.941176, 0.941176)

function Game:LogGameInfo(player, param)
	print("Game Info : ", RunnerGameHandler.GameInfo.GamePhase, RunnerGameHandler.GameInfo.GameTimer)
	print("All Slot List : ", #GRunnerameSlotManager.SlotList, RunnerGameSlotManager.SlotList)
	local busySlotList = RunnerGameSlotManager:GetBusySlotList()
	print("Busy Slot List : ", #busySlotList, busySlotList)
	local enableSlotList = RunnerGameSlotManager:GetEnableSlotList()
	print("Enable Slot List : ", #enableSlotList, enableSlotList)
	print("Player Status : ", PlayerStatus:GetStatusList())
end

return Game
