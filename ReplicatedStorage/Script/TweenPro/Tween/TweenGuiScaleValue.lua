local TweenGuiScaleValue = {}

local Vector2_new = Vector2.new
local UDim2_new = UDim2.new

function TweenGuiScaleValue:GetValue(tweener, target)
	local size = target.Size
	return Vector2_new(size.X.Scale, size.Y.Scale)
end

function TweenGuiScaleValue:SetValue(tweener, target, value)
	local size = target.Size
	target.Size = UDim2_new(value.X, size.X.Offset, value.Y, size.Y.Offset)
end


return TweenGuiScaleValue
