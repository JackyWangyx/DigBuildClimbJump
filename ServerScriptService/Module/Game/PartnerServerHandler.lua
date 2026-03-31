local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)

local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

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
	
	local toopServerHandler = require(game.ServerScriptService.ScriptAlias.ToolServerHandler)
	local car = toopServerHandler:GetTool(player)
	if not car then
		return
	end
	
	local folder = car:FindFirstChild("Partner")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Partner"
		folder.Parent = car
	end
	
	local info = NetServer:RequireModule("Partner"):GetEquip(player)
	if not info then
		return
	end

	local data = ConfigManager:GetData("Partner", info.ID)
	local character = player.Character
	local partnerPrefab = Util:LoadPrefab(data.Prefab)
	if not partnerPrefab then return end
	
	local partnerPoint = Util:GetChildByName(car, "PartnerPoint")
	local partner = partnerPrefab:Clone()
	partner.Parent = folder
	partner:SetPrimaryPartCFrame(partnerPoint.CFrame) 
	
	local humanoid = partner:WaitForChild("Humanoid")
	if partnerPoint:IsA("Seat") or partnerPoint:IsA("VehicleSeat") then
		PartnerServerHandler:InitAnimationSeat(player, partner)
		task.delay(0.1, function()
			if humanoid and partnerPoint.Occupant == nil then
				partnerPoint:Sit(humanoid)
			end
		end)

		PartnerCache[player] = {
			Data = data,
			Partner = partner,
			Seat = partnerPoint,
		}
	else
		PartnerServerHandler:InitAnimation(player, partner)
		
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = partnerPoint
		weld.Part1 = partner.PrimaryPart
		weld.Parent = partner

		PartnerCache[player] = {
			Data = data,
			Partner = partner,
			Constraint = weld,
		}
	end
	
	--PartnerServerHandler:InitPartnerState(player, partner)
end

function PartnerServerHandler:UnEquip(player)
	local data = PartnerCache[player]
	if data then
		if data.Constraint then
			data.Constraint:Destroy()
		end
		
		if data.Seat then
			PartnerServerHandler:LeaveSeat(player)
		end
		
		local partner = data.Partner
		partner:Destroy()
		--task.defer(function()			
		--end)
	end

	PartnerCache[player] = nil
end

function PartnerServerHandler:LeaveSeat(player)
	local data = PartnerCache[player]
	if not data then return end

	local partner = data.Partner
	if not partner then return end

	local humanoid = partner:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.Sit = false
		task.wait()
	end
end

function PartnerServerHandler:InitAnimation(player, partner)
	local carInfo = NetServer:RequireModule("Tool"):GetEquip(player)
	local carData = ConfigManager:GetData("Tool", carInfo.ID)
	
	local humanoid = partner:WaitForChild("Humanoid")
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end
	
	if carData.PartnerAnimation then
		local animation = PlayerManager:GetAnimation(carData.PartnerAnimation)
		local track = animator:LoadAnimation(animation)
		track:Play()
		
		if animator:FindFirstChild("sit") and animator.sit:FindFirstChild("Sit") then
			local animId = "rbxassetid://" .. carData.PartnerAnimation
			animator.sit.Sit.AnimationId = animId
		end
	else
		warn("Tool - Partner Animation NULL", carInfo.ID)
	end
end

function PartnerServerHandler:InitAnimationSeat(player, partner)
	local carInfo = NetServer:RequireModule("Tool"):GetEquip(player)
	local carData = ConfigManager:GetData("Tool", carInfo.ID)

	local humanoid = partner:WaitForChild("Humanoid")
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	if carData.PartnerAnimation then
		local animate = partner:FindFirstChild("Animate")
		local animId = carData.PartnerAnimation
		local sitAnim = animate:FindFirstChild("sit")
		if sitAnim then
			if sitAnim:FindFirstChild("SitAnim") then
				sitAnim.SitAnim.AnimationId = animId
			elseif sitAnim:FindFirstChild("Sit") then
				sitAnim.Sit.AnimationId = animId
			end
		end
	else
		warn("Tool - Partner Animation NULL", carInfo.ID)
	end
end

function PartnerServerHandler:InitPartnerState(player, partner)
	local humanoid = partner.Humanoid
	PlayerManager:DisableHumanoid(humanoid)
end

return PartnerServerHandler