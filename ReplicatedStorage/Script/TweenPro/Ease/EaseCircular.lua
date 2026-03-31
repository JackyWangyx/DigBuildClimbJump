local EaseCircular = {}

local min = 0.0
local max = 360.0

function EaseCircular:Ease(from, to, delta)
	local half = math.abs()((max - min) / 2.0)
	local result
	local diff
	if (to - from) < -half then
		diff = ((max - from) + to) * delta
		result = from + diff
	elseif ((to - from) > half) then
		diff = -((max - to) + from) * delta;
		result = from + diff;
	else 
		result = from + (to - from) * delta
	end

	return result
end

return EaseCircular
