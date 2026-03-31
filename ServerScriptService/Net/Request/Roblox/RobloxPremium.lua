local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)
local TimeUtil = require(game.ReplicatedStorage.ScriptAlias.TimeUtil)
local RobloxUtil = require(game.ReplicatedStorage.ScriptAlias.RobloxUtil)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)

local Define = require(game.ReplicatedStorage.Define)

local RobloxPremium = {}

function RobloxPremium:GetProperty(player)
	local isPremium = RobloxUtil:IsPremium(player)
	if isPremium then
		return {
			IsPremium = true,
			MaxSpeedFactor3 = Define.Game.BuffPremiumValue,
		}
	else
		return {
			IsPremium = false,
			MaxSpeedFactor3 = 0,
		}
	end
end

return RobloxPremium
