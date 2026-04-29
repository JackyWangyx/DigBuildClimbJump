local TweenGuiPositionOffset = {}

local Vector2_new = Vector2.new
local UDim2_new = UDim2.new

function TweenGuiPositionOffset:GetValue(tweener, target)
	return Vector2_new(target.Position.X.Offset, target.Position.Y.Offset)
end

function TweenGuiPositionOffset:SetValue(tweener, target, value)
	target.Position = UDim2_new(target.Position.X.Scale, value.X, target.Position.Y.Scale, value.Y)
end

return TweenGuiPositionOffset
