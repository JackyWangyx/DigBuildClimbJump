local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local Tool = {}

Tool.Icon = "🛠️"
Tool.Color = Color3.new(0.803922, 0.796078, 0.941176)

function Tool:Log(player, param)
	local module = PlayerPrefs:GetModule(player, "Tool")
	print(module)
end

function Tool:Clear(player)
	PlayerPrefs:SetModule(player, "Tool", {})
end

return Tool
