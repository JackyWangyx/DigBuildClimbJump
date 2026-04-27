local NpcManager = {}

function NpcManager:CreateNpcFromPlayerID(playerID, cframe)
	if playerID < 0 then return nil end
	
	local success, result = pcall(function()
		local description = game.Players:GetHumanoidDescriptionFromUserId(playerID)
		local playerName = game.Players:GetNameFromUserIdAsync(playerID)

		local npc = game.Players:CreateHumanoidModelFromDescription(description, Enum.HumanoidRigType.R15)

		npc.Name = playerName
		npc.Parent = game.Workspace
		npc:PivotTo(cframe) 

		local humanoid = npc:WaitForChild("Humanoid")
		local rootPart = npc:WaitForChild("HumanoidRootPart")

		humanoid:ApplyDescription(description)
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer

		rootPart.Anchored = true
		for _, part in ipairs(npc:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("MeshPart") then
				part.CanCollide = false
			end
		end

		humanoid.PlatformStand = true
		humanoid.AutoRotate = false
		
		return npc
	end)
	
	if success then
		return result
	else
		return nil
	end
end

function NpcManager:ScaleNpc(npc, scale)
	if not npc or scale <= 0 then
		return
	end

	local humanoid = npc:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end

	local scales = {
		"BodyHeightScale",
		"BodyWidthScale",
		"BodyDepthScale",
		"HeadScale"
	}

	for _, scaleName in ipairs(scales) do
		local value = humanoid:FindFirstChild(scaleName)
		if not value then
			value = Instance.new("NumberValue")
			value.Name = scaleName
			value.Parent = humanoid
		end
		value.Value = scale
	end

	humanoid.HipHeight = humanoid.HipHeight * scale
end

function NpcManager:PlayAnimation(npc, animationId, isLooped)
	if not npc then return end

	local humanoid = npc:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local track = humanoid:LoadAnimation(animation)
	track.Looped = isLooped or false
	track:Play()

	return track
end

return NpcManager
