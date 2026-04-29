local TweenGuiPositionValue = {}

local Vector2_new = Vector2.new
local UDim2_new = UDim2.new

function TweenGuiPositionValue:GetValue(tweener, target)
	return UDim2_new(target.Position.X.Scale, target.Position.Y.Scale)
end

function TweenGuiPositionValue:SetValue(tweener, target, value)
	target.Position = UDim2_new(value.X, target.Position.X.Offset, value.Y, target.Position.Y.Offset)
end

return TweenGuiPositionValue
