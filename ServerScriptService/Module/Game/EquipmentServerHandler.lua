local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local PlayerAnimation = require(game.ReplicatedStorage.ScriptAlias.PlayerAnimation)

local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)
local AnimalServerHandler = require(game.ServerScriptService.ScriptAlias.AnimalServerHandler)
local PartnerServerHandler = require(game.ServerScriptService.ScriptAlias.PartnerServerHandler)
local EquipmentServerHandler = {}

local EquipmentCache = {}

function EquipmentServerHandler:Init()
	PlayerManager:HandleCharacterAddRemove(function(player, character)
		task.wait(0.5)
		--PlayerManager:SetHeight(player, 10)
		EquipmentServerHandler:Equip(player)
	end, function(player, character)
		EquipmentServerHandler:UnEquip(player)
	end)

	EventManager:Listen(EventManager.Define.RefreshEquipment, function(player)
		--PlayerManager:SetHeight(player, 10)
		EquipmentServerHandler:Equip(player)
	end)
end

function EquipmentServerHandler:GetEquipment(player)
	local info = EquipmentCache[player]
	if not info then return nil end
	return info.Equipment
end

function EquipmentServerHandler:Equip(player)
	local EquipmentCacheData = EquipmentCache[player]
	if EquipmentCacheData then
		EquipmentServerHandler:UnEquip(player)
	end
	
	local info = NetServer:RequireModule("Equipment"):GetEquip(player)
	if not info then
		return
	end

	local data = ConfigManager:GetData("Equipment", info.ID)
	--local character = player.Character
	--local EquipmentPrefab = Util:LoadPrefab(data.Prefab)
	--local equipment = EquipmentPrefab:Clone()
	--equipment.Name = "Equipment"
	--equipment.Parent = character

	EquipmentCache[player] = {
		Data = data,
		Equipment = nil,
	}
	
	--AnimalServerHandler:Refresh(player)
	EquipmentServerHandler:ShowEquipment(player)
	PartnerServerHandler:Refresh(player)
end

function EquipmentServerHandler:ShowEquipment(player)
	local info = EquipmentCache[player]
	if info and not info.Equipment then
		local EquipmentPrefab = Util:LoadPrefab(info.Data.Prefab)
		local equipment = EquipmentPrefab:Clone()
		local character = player.Character
		equipment.Name = "Equipment"
		equipment.Parent = character
		info.Equipment = equipment
	end
end

function EquipmentServerHandler:HideEquipment(player)
	local info = EquipmentCache[player]
	if info and info.Equipment then
		info.Equipment:Destroy()
		info.Equipment = nil
	end
end

function EquipmentServerHandler:UnEquip(player)
	local info = EquipmentCache[player]
	if info then
		--PlayerAnimation:StopAnimation(player, info.Data.RunAnimation)

		--EventManager:DispatchToClient(player, EventManager.Define.DriveEnd)
		--NetServer:Broadcast(player, "Player", "EnableFootstepSounds")
		if info.Equipment then
			info.Equipment:Destroy()
		end
	end

	EquipmentCache[player] = nil
end

return EquipmentServerHandler