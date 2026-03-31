local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)
local TimeUtil = require(game.ReplicatedStorage.ScriptAlias.TimeUtil)
local FriendManager = require(game.ReplicatedStorage.ScriptAlias.FriendManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)

local Define = require(game.ReplicatedStorage.Define)

local Friend = {}

function Friend:GetProperty(player)
	local count = Friend:GetOnlineCount(player)
	local property = {
		MaxSpeedFactor3 = count * Define.Game.BuffInviteValue
	}
	
	return property
end

function Friend:GetOnlineCount(player)
	local result = FriendManager:GetFriendOnlineCount(player)
	return result
end

return Friend
