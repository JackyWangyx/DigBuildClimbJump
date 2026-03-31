local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)

local PlayerCache = {}

local CacheData = {}

function PlayerCache:Init()
	PlayerManager:HandlePlayerAddRemove(function(player)
		PlayerCache:InitLoginTime(player)
	end, function(player)
		PlayerCache:Clear(player)
	end)
end

-- API

function PlayerCache:GetCacheData(player)
	if not player then return nil end
	local data = CacheData[player]
	if not data then 
		data = {}
		CacheData[player] = data
	end
	return data
end

function PlayerCache:SetValue(player, key, value)
	if not player then return end
	local data = PlayerCache:GetCacheData(player)
	data[key] = value
end

function PlayerCache:GetValue(player, key)
	if not player then return end
	local data = PlayerCache:GetCacheData(player)
	local result = data[key]
	return result
end

function PlayerCache:Clear(player)
	if not player then return end
	CacheData[player] = nil
end

-- Data

function PlayerCache:InitLoginTime(player)
	local value = os.time()
	PlayerCache:SetValue(player, "LoginTime", value)
end

function PlayerCache:GetLoginTime(player)
	local result = PlayerCache:GetValue(player, "LoginTime")
	if not result then
		PlayerCache:InitLoginTime(player)
		result = PlayerCache:GetValue(player, "LoginTime")
	end
	return result
end

function PlayerCache:GetOnlineTime(player)
	local value = os.time()
	local loginTime = PlayerCache:GetLoginTime(player)
	local result = value - loginTime
	return result
end

return PlayerCache
