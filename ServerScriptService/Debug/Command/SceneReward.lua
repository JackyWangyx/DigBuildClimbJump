local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local SceneReward = {}

SceneReward.Icon = "🎁"
SceneReward.Color = Color3.new(0.941176, 0.631373, 0.92549)

function SceneReward:Log(player, param)
	local module = PlayerPrefs:GetModule(player, "SceneReward")
	print(module)
end

function SceneReward:Clear(player)
	PlayerPrefs:SetModule(player, "SceneReward", {})
end

return SceneReward
