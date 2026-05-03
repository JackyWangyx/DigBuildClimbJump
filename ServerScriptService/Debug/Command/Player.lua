local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local PlayerProperty = require(game.ServerScriptService.ScriptAlias.PlayerProperty)
local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local Player = {}

Player.Icon = "🆔"
Player.Color = Color3.new(0.985199, 0.85919, 0.0818494)

function Player:SaveProperty(player, param)
	local saveInfo = PlayerPrefs:GetModule(player, PlayerProperty.DATA_MODULE_KEY)
	print("[Property] 📝", saveInfo)
end

function Player:GameProperty(player, param)
	local property = PlayerProperty:GetGameProperty(player)
	print("[Property] 📝", property)
end

function Player:Record(player)
	local record = PlayerRecord:GetRecord(player)
	print("[Property] 📝", record)
end

function Player:AddMaxSpeedMultiply(player)
	local value = PlayerProperty:GetGamePropertyValue(player, PlayerProperty.Define.MAX_SPEED_FACTOR)
	value += 1
	PlayerProperty:SetPlayerPropertyValue(player, PlayerProperty.Define.MAX_SPEED_FACTOR, value)
end

function Player:AddAcceleration(player)
	local value = PlayerProperty:GetGamePropertyValue(player, PlayerProperty.Define.ACCELERATION)
	value += 1
	PlayerProperty:SetPlayerPropertyValue(player, PlayerProperty.Define.ACCELERATION, value)
end

function Player:Donate5(player)
	local donateRank = require(game.ServerScriptService.ScriptAlias.DonateRank)
	donateRank:Donate(player, 1)
end

return Player
