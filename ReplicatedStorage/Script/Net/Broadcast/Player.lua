local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local EventMananger = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)

local Player = {}

function Player:EnableFootstepSounds(player)
	PlayerManager:EnableFootstepSounds(player)
end

function Player:DisableFootstepSounds(player)
	PlayerManager:DisableFootstepSounds(player)
end

return Player
