local TweenPlayerRotation = {}

local function getRootPart(player)
	if not player then return nil end
	local character = player.Character
	if not character then return nil end
	return character:FindFirstChild("HumanoidRootPart")
end

function TweenPlayerRotation:GetValue(tweener, target)
	local rootPart = getRootPart(target)
	if not rootPart then return nil end
	return rootPart.CFrame.Rotation
end

function TweenPlayerRotation:SetValue(tweener, target, value)
	local rootPart = getRootPart(target)
	if not rootPart then return end
	local pos = rootPart.Position
	rootPart.CFrame = CFrame.new(pos) * value
end

return TweenPlayerRotation
