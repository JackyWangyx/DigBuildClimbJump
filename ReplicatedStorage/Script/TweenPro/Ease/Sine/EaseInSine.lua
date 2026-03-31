local EaseInSine = {}

function EaseInSine:Ease(from, to, delta)
	local range = to - from
	return -range * math.cos(delta * (math.pi / 2)) + range + from
end

return EaseInSine
