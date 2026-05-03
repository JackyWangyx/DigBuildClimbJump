local TweenGuiPositionOffset = {}

local Vector2_new = Vector2.new
local UDim2_new = UDim2.new

function TweenGuiPositionOffset:GetValue(tweener, target)
	local pos = target.Position
	return Vector2_new(pos.X.Offset, pos.Y.Offset)
end

function TweenGuiPositionOffset:SetValue(tweener, target, value)
	local pos = target.Position
	target.Position = UDim2_new(pos.X.Scale, value.X, pos.Y.Scale, value.Y)
end

return TweenGuiPositionOffset
