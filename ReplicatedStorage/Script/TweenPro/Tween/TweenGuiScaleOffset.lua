local TweenGuiScaleOffset = {}

function TweenGuiScaleOffset:GetValue(tweener, target)
	return Vector2.new(target.Size.X.Offset, target.Size.Y.Offset)
end

function TweenGuiScaleOffset:SetValue(tweener, target, value)
	target.Size = UDim2.new(target.Size.X.Scale, value.X, target.Size.Y.Scale, value.Y)
end

return TweenGuiScaleOffset
