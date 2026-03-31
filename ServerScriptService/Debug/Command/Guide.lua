local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local Guide = {}

Guide.Icon = "✨"
Guide.Color = Color3.new(0.843137, 0.941176, 0.917647)

function Guide:Log(player, param)
	local module = PlayerPrefs:GetModule(player, "Guide")
	print(module)
end

function Guide:Clear(player)
	PlayerPrefs:SetModule(player, "Guide", {})
end

return Guide
