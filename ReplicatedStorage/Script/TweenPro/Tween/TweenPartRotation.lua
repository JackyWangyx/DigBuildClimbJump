local TweenPartRotation = {}

function TweenPartRotation:GetValue(tweener, target)
	return target.Orientation
end

function TweenPartRotation:SetValue(tweener, target, value)
	target.CFrame = CFrame.new(pos) * CFrame.Angles(
		math.rad(value.X),
		math.rad(value.Y),
		math.rad(value.Z)
	)
end

return TweenPartRotation
