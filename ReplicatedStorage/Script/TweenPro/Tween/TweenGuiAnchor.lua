local TweenGuiAnchor = {}

function TweenGuiAnchor:GetValue(tweener, target)
	return target.AnchorPoint
end

function TweenGuiAnchor:SetValue(tweener, target, value)
	target.AnchorPoint = value
end

return TweenGuiAnchor