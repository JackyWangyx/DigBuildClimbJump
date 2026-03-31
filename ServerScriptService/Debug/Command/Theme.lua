local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local Theme = {}

Theme.Icon = "🌈"
Theme.Color = Color3.new(0.941176, 0.941176, 0)

function Theme:Log(player, param)
	local module = PlayerPrefs:GetModule(player, "Theme")
	print(module)
end

function Theme:Clear(player)
	PlayerPrefs:SetModule(player, "Theme", {})
end

return Theme
