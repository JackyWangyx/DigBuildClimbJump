local TweenPartPosition = {}

function TweenPartPosition:GetValue(tweener, target)
	return target.Position
end

function TweenPartPosition:SetValue(tweener, target, value)
	target.Position = value
end

return TweenPartPosition
