local TweenCameraFOV = {}

function TweenCameraFOV:GetValue(tweener, target)
	return target.FieldOfView
end

function TweenCameraFOV:SetValue(tweener, target, value)
	target.FieldOfView = value
end

return TweenCameraFOV
