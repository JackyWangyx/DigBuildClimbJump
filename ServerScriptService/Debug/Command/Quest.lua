local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local AnimalRequest = require(game.ServerScriptService.ScriptAlias.Animal)

local Quest = {}

Quest.Icon = "📝"
Quest.Color = Color3.new(0.635294, 0.878431, 0.984314)

function Quest:Log(player, param)
	local module = PlayerPrefs:GetModule(player, "Quest")
	print(module)
end

function Quest:Clear(player)
	PlayerPrefs:SetModule(player, "Quest", {})
end

return Quest
