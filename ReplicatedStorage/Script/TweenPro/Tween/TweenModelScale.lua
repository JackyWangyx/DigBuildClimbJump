local TweenModelScale = {}

function TweenModelScale:GetValue(tweener, target)
	return target:GetExtentsSize()
end

function TweenModelScale:SetValue(tweener, target, value)
	local currentSize = target:GetExtentsSize()
	if currentSize.Magnitude == 0 then return end
	local scaleX = value.X / currentSize.X
	local scaleY = value.Y / currentSize.Y
	local scaleZ = value.Z / currentSize.Z
	local uniformScale = (scaleX + scaleY + scaleZ) / 3
	target:ScaleTo(uniformScale)
end

return TweenModelScale
