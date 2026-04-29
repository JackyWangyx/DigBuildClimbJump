local TweenModelPosition = {}

local CFrame_fromMatrix = CFrame.fromMatrix

function TweenModelPosition:GetValue(tweener, target)
	return target:GetPivot().Position
end

function TweenModelPosition:SetValue(tweener, target, value)
	local pivot = target:GetPivot()
	local rX, rY, rZ = pivot.XVector, pivot.YVector, pivot.ZVector
	target:PivotTo(CFrame_fromMatrix(value, rX, rY, rZ))
end

return TweenModelPosition