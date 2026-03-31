local EaseInOutSine = {}

function EaseInOutSine:Ease(from, to, delta)
	local range = to - from
	return -range / 2 * (math.cos(math.pi * delta) - 1) + from
end

return EaseInOutSine
