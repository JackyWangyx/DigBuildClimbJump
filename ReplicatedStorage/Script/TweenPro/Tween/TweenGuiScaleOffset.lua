local TweenGuiScaleOffset = {}

local Vector2_new = Vector2.new
local UDim2_new = UDim2.new

function TweenGuiScaleOffset:GetValue(tweener, target)
	local size = target.Size
	return Vector2_new(size.X.Offset, size.Y.Offset)
end

function TweenGuiScaleOffset:SetValue(tweener, target, value)
	local size = target.Size
	target.Size = UDim2_new(size.X.Scale, value.X, size.Y.Scale, value.Y)
end

return TweenGuiScaleOffset
