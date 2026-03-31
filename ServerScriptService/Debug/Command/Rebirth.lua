local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local Rebirth = {}

Rebirth.Icon = "♻️"
Rebirth.Color = Color3.new(0.760784, 0.941176, 0.615686)

function Rebirth:Log(player, param)
	local rebirthRequset = NetServer:RequireModule("Rebirth")
	local info = rebirthRequset:GetInfo(player)
	print(info)
end

function Rebirth:Clear(player)
	PlayerPrefs:SetModule(player, "Rebirth", {})
end

return Rebirth