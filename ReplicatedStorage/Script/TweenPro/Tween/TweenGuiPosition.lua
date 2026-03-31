local TweenGuiPosition = {}

function TweenGuiPosition:GetValue(tweener, target)
	return target.Position
end

function TweenGuiPosition:SetValue(tweener, target, value)
	target.Position = value
end

return TweenGuiPosition
