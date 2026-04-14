local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local SceneManager = require(game.ReplicatedStorage.ScriptAlias.SceneManager)

local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local ClimbTowerDefine = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerDefine)

local PartnerServerHandler = {}

local PartnerCache = {}

function PartnerServerHandler:Init()
	PlayerManager:HandleCharacterAddRemove(function(player, character)

	end, function(player, character)
		PartnerServerHandler:UnEquip(player)
	end)

	EventManager:Listen(EventManager.Define.RefreshPartner, function(player)
		PartnerServerHandler:Equip(player)
	end)
end

function PartnerServerHandler:Refresh(player)
	PartnerServerHandler:UnEquip(player)
	PartnerServerHandler:Equip(player)
end

function PartnerServerHandler:Equip(player)
	local cacheData = PartnerCache[player]
	if cacheData then
		PartnerServerHandler:UnEquip(player)
	end
	
	local info = NetServer:RequireModule("Partner"):GetEquip(player)
	if not info then
		return
	end

	local data = ConfigManager:GetData("Partner", info.ID)
	local character = player.Character
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	local humanoid = PlayerManager:GetHumanoid(player)
	local partnerPrefab = Util:LoadPrefab(data.Prefab)
	if not partnerPrefab then return end
	
	local partner = partnerPrefab:Clone()
	partner.Parent = character
	
	local partnerAnimation = game.ReplicatedStorage.LocalScript.PartnerAnimation:Clone()
	partnerAnimation.Parent = partner
	
	-- 初始化动画（保持你原来的逻辑）
	local humanoid = partner:WaitForChild("Humanoid", 5)
	if humanoid then
		--PartnerServerHandler:InitAnimation(player, partner)
	end
	
	local weld = Instance.new("Weld")
	weld.Name = "Weld_Partner_Player"
	weld.Part0 = rootPart
	weld.Part1 = partner.PrimaryPart
	weld.C0 = CFrame.new(0, 0, 0)
	weld.Parent = partner.PrimaryPart

	-- 更新缓存
	PartnerCache[player] = {
		Data = data,
		Partner = partner,
		Weld = weld,
	}
	
	PartnerServerHandler:SetOffset(player, ClimbTowerDefine.Game.PartnerIdleOffset)
	--PartnerServerHandler:InitPartnerState(player, partner)
end

function PartnerServerHandler:SetOffset(player, offset)
	local info = PartnerCache[player]
	if not info then return end
	
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	local offsetCFrame = CFrame.new(offset)
	
	info.Weld.C1 = offsetCFrame:Inverse()
	--info.Partner:PivotTo(rootPart.CFrame * offsetCFrame)
end

function PartnerServerHandler:UnEquip(player)
	local info = PartnerCache[player]
	if info then
		if info.Weld then
			info.Weld:Destroy()
		end
		
		if info.AttachmentList then
			for _, attachment in ipairs(info.AttachmentList) do
				attachment:Destroy()
			end
		end
		
		local partner = info.Partner
		partner:Destroy()
		--task.defer(function()			
		--end)
	end

	PartnerCache[player] = nil
end

function PartnerServerHandler:LeaveSeat(player)
	local info = PartnerCache[player]
	if not info then return end

	local partner = info.Partner
	if not partner then return end

	local humanoid = partner:FindFirstChild("Humanoid")
	if humanoid then
		--humanoid.Sit = false
		--task.wait()
	end
end

function PartnerServerHandler:InitPartnerState(player, partner)
	local humanoid = partner.Humanoid
	PlayerManager:DisableHumanoid(humanoid)
end

return PartnerServerHandler