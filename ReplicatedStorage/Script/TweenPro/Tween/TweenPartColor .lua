local TweenPartColor = {}

function TweenPartColor:GetValue(tweener, target)
	return target.Color
end

function TweenPartColor:SetValue(tweener, target, value)
	target.Color = value
end

return TweenPartColor
