local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local ClimbTowerDefine = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerDefine)

local ClimbTower = {}

ClimbTower.Icon = "🎢"
ClimbTower.Color = Color3.new(0.941176, 0.741176, 0.498039)

function ClimbTower:LogSave(player, param)
	local module = PlayerPrefs:GetModule(player, "ClimbTower")
	print(module)
end

function ClimbTower:GameProprerty(player, param)
	EventManager:DispatchToClient(player, ClimbTowerDefine.Event.LogGameProperty)
end

function ClimbTower:Clear(player)
	PlayerPrefs:SetModule(player, "ClimbTower", {})
end

return ClimbTower
