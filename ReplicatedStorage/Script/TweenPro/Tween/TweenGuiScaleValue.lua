local TweenGuiScaleValue = {}

function TweenGuiScaleValue:GetValue(tweener, target)
	return Vector2.new(target.Size.X.Scale, target.Size.Y.Scale)
end

function TweenGuiScaleValue:SetValue(tweener, target, value)
	target.Size = UDim2.new(value.X, target.Size.X.Offset, value.Y, target.Size.Y.Offset)
end


return TweenGuiScaleValue
