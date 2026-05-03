local TweenGuiPositionValue = {}

local Vector2_new = Vector2.new
local UDim2_new = UDim2.new

function TweenGuiPositionValue:GetValue(tweener, target)
	local pos = target.Position
	return UDim2_new(pos.X.Scale, pos.Y.Scale)
end

function TweenGuiPositionValue:SetValue(tweener, target, value)
	local pos = target.Position
	target.Position = UDim2_new(value.X, pos.X.Offset, value.Y, pos.Y.Offset)
end

return TweenGuiPositionValue
