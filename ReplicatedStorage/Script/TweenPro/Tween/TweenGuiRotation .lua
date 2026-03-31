local TweenGuiRotation = {}

function TweenGuiRotation:GetValue(tweener, target)
	return target.Rotation
end

function TweenGuiRotation:SetValue(tweener, target, value)
	target.Rotation = value
end

return TweenGuiRotation
