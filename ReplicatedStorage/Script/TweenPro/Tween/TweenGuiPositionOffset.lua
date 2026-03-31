local TweenGuiPositionOffset = {}

function TweenGuiPositionOffset:GetValue(tweener, target)
	return Vector2.new(target.Position.X.Offset, target.Position.Y.Offset)
end

function TweenGuiPositionOffset:SetValue(tweener, target, value)
	target.Position = UDim2.new(target.Position.X.Scale, value.X, target.Position.Y.Scale, value.Y)
end

return TweenGuiPositionOffset
