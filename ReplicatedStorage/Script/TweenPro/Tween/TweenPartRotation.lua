local TweenPartRotation = {}

local CFrame_new = CFrame.new
local CFrame_Angles = CFrame.Angles
local math_rad = math.rad

function TweenPartRotation:GetValue(tweener, target)
	return target.Orientation
end

function TweenPartRotation:SetValue(tweener, target, value)
	target.CFrame = CFrame_new(target.CFrame.Position) * CFrame_Angles(
		math_rad(value.X),
		math_rad(value.Y),
		math_rad(value.Z)
	)
end

return TweenPartRotation
