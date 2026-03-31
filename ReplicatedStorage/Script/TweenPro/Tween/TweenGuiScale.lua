local TweenGuiScale = {}

function TweenGuiScale:GetValue(tweener, target)
	return target.Size
end

function TweenGuiScale:SetValue(tweener, target, value)
	target.Size = value
end

return TweenGuiScale
