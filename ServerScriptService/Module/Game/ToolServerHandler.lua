local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local PlayerAnimation = require(game.ReplicatedStorage.ScriptAlias.PlayerAnimation)

local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)
local AnimalServerHandler = require(game.ServerScriptService.ScriptAlias.AnimalServerHandler)
local PartnerServerHandler = require(game.ServerScriptService.ScriptAlias.PartnerServerHandler)
local ToolServerHandler = {}

local ToolCache = {}

function ToolServerHandler:Init()
	PlayerManager:HandleCharacterAddRemove(function(player, character)
		task.wait(0.5)
		--PlayerManager:SetHeight(player, 10)
		ToolServerHandler:Equip(player)
	end, function(player, character)
		ToolServerHandler:UnEquip(player)
	end)

	EventManager:Listen(EventManager.Define.RefreshTool, function(player)
		--PlayerManager:SetHeight(player, 10)
		ToolServerHandler:Equip(player)
	end)
end

function ToolServerHandler:GetTool(player)
	local info = ToolCache[player]
	if not info then return nil end
	return info.Tool
end

function ToolServerHandler:Equip(player)
	local toolCacheData = ToolCache[player]
	if toolCacheData then
		ToolServerHandler:UnEquip(player)
	end
	local info = NetServer:RequireModule("Tool"):GetEquip(player)
	if not info then
		return
	end

	local data = ConfigManager:GetData("Tool", info.ID)
	local character = player.Character
	local toolPrefab = Util:LoadPrefab(data.Prefab)
	local tool = toolPrefab:Clone()
	tool.Name = "Tool_"..toolPrefab.Name
	tool.Parent = character
	--PlayerAnimation:PlayAnimation(player, data.RunAnimation, true, 1)

	if data.Type == "Tool" then
	elseif data.Type == "Car" then
		PlayerManager:DisableJump(player)
		NetServer:Broadcast(player, "Player", "DisableFootstepSounds")
	end

	--PlayerManager:SetMoveHeight(player, data.HipHeight)
	
	ToolCache[player] = {
		Data = data,
		Tool = tool,
	}
	
	--AnimalServerHandler:Refresh(player)
	PartnerServerHandler:Refresh(player)
end

function ToolServerHandler:UnEquip(player)
	local info = ToolCache[player]
	if info then
		--PlayerAnimation:StopAnimation(player, info.Data.RunAnimation)

		if info.Data.Type == "Car" then
			PlayerManager:EnableJump(player)
			NetServer:Broadcast(player, "Player", "EnableFootstepSounds")
			EventManager:DispatchToClient(player, EventManager.Define.DriveEnd)
		end

		--PlayerManager:SetDefaultMoveHeight(player)
		
		
		--NetServer:Broadcast(player, "Player", "EnableFootstepSounds")
		info.Tool:Destroy()
	end

	ToolCache[player] = nil
end

return ToolServerHandler