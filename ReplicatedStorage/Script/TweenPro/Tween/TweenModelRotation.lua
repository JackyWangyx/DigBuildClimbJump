local TweenModelRotation = {}

local Vector3_new = Vector3.new
local CFrame_new = CFrame.new
local CFrame_Angles = CFrame.Angles
--local math_deg = math.deg
--local math_rad = math.rad

local RAD = math.pi / 180
local DEG = 180 / math.pi

function TweenModelRotation:GetValue(tweener, target)
	local rx, ry, rz = target:GetPivot():ToOrientation()
	return Vector3_new(rx * DEG, ry * DEG, rz * DEG)
end

function TweenModelRotation:SetValue(tweener, target, value)
	local pivot = target:GetPivot()
	local pos = pivot.Position
	local rx = value.X * RAD
	local ry = value.Y * RAD
	local rz = value.Z * RAD
	target:PivotTo(CFrame_new(pos) * CFrame_Angles(rx, ry, rz))
end

return TweenModelRotation
