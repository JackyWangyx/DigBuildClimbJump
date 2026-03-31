local TweenPartScale = {}

function TweenPartScale:GetValue(tweener, target)
	return target.Size
end

function TweenPartScale:SetValue(tweener, target, value)
	target.Size = value
end

return TweenPartScale
