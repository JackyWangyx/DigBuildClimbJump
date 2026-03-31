local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local SceneManager = require(game.ReplicatedStorage.ScriptAlias.SceneManager)

local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local PetFolder = nil
local PetServerHandler = {}

local PetCacheList = {}
local AttachmentCacheList = {}
local PetFormationCache = {}
local FollowTargets = {}

function PetServerHandler:Init()
	PetFolder = SceneManager.LevelRoot.Game:WaitForChild("Pet")

	PlayerManager:HandlePlayerAddRemove(function(player)
		PetServerHandler:Create(player)
	end, function(player, character)
		PetServerHandler:Clear(player)
	end)

	EventManager:Listen(EventManager.Define.RefreshPet, function(player)
		PetServerHandler:Refresh(player)
	end)

	PlayerManager:HandleCharacterAddRemove(function(player, character)
		PetServerHandler:RefreshCache(player)
	end, function(player, character)
		PetServerHandler:RefreshCache(player)
	end)

	--RunService.Heartbeat:Connect(function(deltaTime)
	--	PetSeverHandler:Update(deltaTime)
	--end)
end

function PetServerHandler:Refresh(player)
	PetServerHandler:Clear(player)
	PetServerHandler:Create(player)
end

function PetServerHandler:Create(player)
	local petInfoList = NetServer:RequireModule("Pet"):GetEquipList(player)
	local petList = PetServerHandler:GetPetList(player)
	local count = #petInfoList
	local attachmentList = PetServerHandler:GetAttachmentList(player)
	local petFormationList = PetServerHandler:GetFormation(count)
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	if not rootPart then return end
	for index, petInfo in ipairs(petInfoList) do
		local petFormation = petFormationList[index]
		local relativePosition = petFormation.Position
		local relativeRotation = petFormation.Orientation

		-- Pet
		local id = petInfo.ID
		local data = ConfigManager:GetData("Pet", id)
		if not data then 
			warn("[Pet Handler] PetData not found!", id)
			continue 
		end
		
		local prefab = Util:LoadPrefab(data.Prefab)
		if not prefab then 
			warn("[Pet Handler] Pet prefab not found!", id, data.Prefab)
			continue 
		end
		
		local pet = prefab:Clone()
		pet.Parent = PetFolder
		pet.Name = "Pet_"..player.UserId.."_"..data.Name
		table.insert(petList, pet)

		-- 设置相对CFrame
		local relativeCFrame = CFrame.new(relativePosition) * CFrame.Angles(relativeRotation.X, relativeRotation.Y, relativeRotation.Z)
		local worldCFrame = rootPart.CFrame * relativeCFrame
		pet:SetPrimaryPartCFrame(worldCFrame)

		-- 使用 WeldConstraint 刚性跟随
		local attachmentPart = Instance.new("Part")
		attachmentPart.Size = Vector3.new(1,1,1)
		attachmentPart.Transparency = 1
		attachmentPart.Anchored = false
		attachmentPart.CanCollide = false
		attachmentPart.CFrame = worldCFrame
		attachmentPart.Parent = rootPart
		attachmentPart:SetNetworkOwner(player)

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = rootPart
		weld.Part1 = attachmentPart
		weld.Parent = attachmentPart

		local petWeld = Instance.new("WeldConstraint")
		petWeld.Part0 = attachmentPart
		petWeld.Part1 = pet.PrimaryPart
		petWeld.Parent = pet.PrimaryPart

		pet:PivotTo(rootPart.CFrame * relativeCFrame)

		table.insert(attachmentList, attachmentPart)
		
		--pet:SetNetworkOwner(player)
	end
end

function PetServerHandler:GetPetList(player)
	local petList = PetCacheList[player]
	if not petList then
		petList = {}
		PetCacheList[player] = petList
	end
	return petList
end

function PetServerHandler:GetAttachmentList(player)
	local attachmentList = AttachmentCacheList[player]
	if not attachmentList then
		attachmentList = {}
		AttachmentCacheList[player] = attachmentList
	end
	return attachmentList
end

function PetServerHandler:Clear(player)
	local petList = PetServerHandler:GetPetList(player)
	for _, pet in ipairs(petList) do
		pet:Destroy()
	end
	local attachmentList = PetServerHandler:GetAttachmentList(player)
	for _, attachment in ipairs(attachmentList) do
		attachment:Destroy()
	end

	petList = {}
	PetCacheList[player] = nil
	AttachmentCacheList[player] = nil
end

function PetServerHandler:GetFormation(count)
	local result = PetFormationCache[count]
	if not result then
		local formationList = {}
		local folder = game.ReplicatedStorage.Module.Pet:WaitForChild("PetFormation")
		local formation = folder:FindFirstChild(tostring(count))
		if not formation then
			return formationList
		end
		for _, part in ipairs(formation:GetChildren()) do
			table.insert(formationList, {
				Position = part.Position,
				Orientation = part.Orientation
			})
		end	
		result = formationList
		PetFormationCache[count] = formationList
	end
	return result
end

function PetServerHandler:RefreshCache(player)
	PetCacheList[player] = nil
end

return PetServerHandler