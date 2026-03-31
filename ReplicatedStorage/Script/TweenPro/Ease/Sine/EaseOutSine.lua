local EaseOutSine = {}

function EaseOutSine:Ease(from, to, delta)
	local range = to - from
	return range * math.sin(delta * (math.pi / 2)) + from
end

return EaseOutSine
