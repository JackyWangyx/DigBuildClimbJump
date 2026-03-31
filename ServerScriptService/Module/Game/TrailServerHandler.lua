local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)

local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local TrailServerHandler = {}

local TrailCache = {}

function TrailServerHandler:Init()
	PlayerManager:HandleCharacterAddRemove(function(player, character)
		task.wait(1)
		TrailServerHandler:Equip(player)
	end, function(player, character)
		TrailServerHandler:UnEquip(player)
	end)

	EventManager:Listen(EventManager.Define.RefreshTrail, function(player)
		TrailServerHandler:Equip(player)
	end)
end

function TrailServerHandler:Equip(player)
	local TrailCacheData = TrailCache[player]
	if TrailCacheData then
		TrailServerHandler:UnEquip(player)
	end
	local info = NetServer:RequireModule("Trail"):GetEquip(player)
	if not info then
		return
	end

	local data = ConfigManager:GetData("Trail", info.ID)
	local character = player.Character
	local TrailPrefab = Util:LoadPrefab(data.Prefab)
	local Trail = TrailPrefab:Clone()
	Trail.Handle.CanCollide = false
	Trail.Parent = character
	TrailCache[player] = {
		Data = data,
		Trail = Trail,
	}
end

function TrailServerHandler:UnEquip(player)
	local data = TrailCache[player]
	if data then
		data.Trail:Destroy()
	end

	TrailCache[player] = nil
end

return TrailServerHandler