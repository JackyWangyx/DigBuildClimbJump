local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local Partner = {}

Partner.Icon = "🧑"
Partner.Color = Color3.new(0.941176, 0.741176, 0.498039)

function Partner:Log(player, param)
	local module = PlayerPrefs:GetModule(player, "Partner")
	print(module)
end

function Partner:Clear(player)
	PlayerPrefs:SetModule(player, "Partner", {})
end

return Partner
