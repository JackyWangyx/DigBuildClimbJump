local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local Trail = {}

Trail.Icon = "💫"
Trail.Color = Color3.new(0.835294, 0.941176, 0.85098)

function Trail:Log(player, param)
	local module = PlayerPrefs:GetModule(player, "Trail")
	print(module)
end

function Trail:Clear(player)
	PlayerPrefs:SetModule(player, "Trail", {})
end

return Trail
