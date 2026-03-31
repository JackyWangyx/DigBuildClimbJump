local EaseParabola = {}

function EaseParabola:Ease(from, to, delta)
	local range = to - from
	local half = range / 2
	local result = range - ((delta - half) * range * 2) ^ 2
	return result
end

return EaseParabola
