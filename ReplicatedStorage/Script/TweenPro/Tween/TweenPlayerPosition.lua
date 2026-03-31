local TweenPlayerPosition = {}

local function getRootPart(player)
	if not player then return nil end
	local character = player.Character
	if not character then return nil end
	return character:FindFirstChild("HumanoidRootPart")
end

function TweenPlayerPosition:GetValue(tweener, target)
	local rootPart = getRootPart(target)
	if not rootPart then return end
	return rootPart.Position
end

function TweenPlayerPosition:SetValue(tweener, target, value)
	local rootPart = getRootPart(target)
	if not rootPart then return end
	local rotation = rootPart.CFrame.Rotation
	rootPart.CFrame = CFrame.new(value) * rotation
end

return TweenPlayerPosition
