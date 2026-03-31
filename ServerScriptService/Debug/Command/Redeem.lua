local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)

local Redeem = {}

Redeem.Icon = "🎫"
Redeem.Color = Color3.new(0.694118, 0.882353, 0.00784314)

function Redeem:Log(player, param)
	local module = PlayerPrefs:GetModule(player, "Redeem")
	print(module)
end

function Redeem:Clear(player)
	PlayerPrefs:SetModule(player, "Redeem", {})
end

return Redeem
