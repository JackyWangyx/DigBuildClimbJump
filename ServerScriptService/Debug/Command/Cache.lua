local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local PlayerCache = require(game.ServerScriptService.ScriptAlias.PlayerCache)

local Cache = {}

Cache.Icon = "📑"
Cache.Color = Color3.new(0.736355, 0.985199, 0)

function Cache:Log(player)
	local data = PlayerCache:GetCacheData(player)
	print(data)
end

function Cache:Clear(player)
	PlayerCache:Clear(player)
end

return Cache
