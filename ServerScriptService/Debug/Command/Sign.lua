local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)

local Sign = {}

Sign.Icon = "📅"
Sign.Color = Color3.new(0.027451, 0.941176, 0.592157)

function Sign:Log(player, param)
	local module = PlayerPrefs:GetModule(player, "Sign")
	print(module)
end

function Sign:Clear(player)
	PlayerPrefs:SetModule(player, "Sign", {})
end

return Sign
