local TweenGuiPositionValue = {}

function TweenGuiPositionValue:GetValue(tweener, target)
	return Vector2.new(target.Position.X.Scale, target.Position.Y.Scale)
end

function TweenGuiPositionValue:SetValue(tweener, target, value)
	target.Position = UDim2.new(value.X, target.Position.X.Offset, value.Y, target.Position.Y.Offset)
end

return TweenGuiPositionValue
