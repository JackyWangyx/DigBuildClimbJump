local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local ServerPrefs = require(game.ServerScriptService.ScriptAlias.ServerPrefs)
local GameRank = require(game.ServerScriptService.ScriptAlias.GameRank)

local Save = {}

Save.Icon = "💾"
Save.Color = Color3.new(1, 0.307256, 0)

function Save:LogServer(player, param)
	local data = ServerPrefs:GetCache()
	print(data)
end

function Save:LogPlayer(player, param)
	local data = PlayerPrefs:GetPlayerSaveInfo(player)
	print(data)
end

function Save:ClearServer(player)
	ServerPrefs:ClearInternal()
end

function Save:ClearPlayer(player)
	PlayerPrefs:ClearPlayer(player)
end

function Save:SaveRank(player)
	GameRank:ForceUpdateRank(false)
end

return Save
