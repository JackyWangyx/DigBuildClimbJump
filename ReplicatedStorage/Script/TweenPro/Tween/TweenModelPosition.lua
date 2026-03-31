local TweenModelPosition = {}

function TweenModelPosition:GetValue(tweener, target)
	return target:GetPivot().Position
end

function TweenModelPosition:SetValue(tweener, target, value)
	local pivot = target:GetPivot()
	local rotation = pivot - pivot.Position
	target:PivotTo(CFrame.new(value) * rotation)
end

return TweenModelPosition
