local TweenModelRotation = {}

function TweenModelRotation:GetValue(tweener, target)
	local rx, ry, rz = target:GetPivot():ToOrientation()
	return Vector3.new(math.deg(rx), math.deg(ry), math.deg(rz))
end

function TweenModelRotation:SetValue(tweener, target, value)
	local pivot = target:GetPivot()
	local pos = pivot.Position
	target:PivotTo(
		CFrame.new(pos) * CFrame.Angles(
			math.rad(value.X),
			math.rad(value.Y),
			math.rad(value.Z)
		)
	)
end

return TweenModelRotation
