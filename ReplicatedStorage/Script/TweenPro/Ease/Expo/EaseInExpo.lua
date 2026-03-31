local EaseInExpo = {}

function EaseInExpo:Ease(from, to, delta)
	to = to - from
	return to * 2^(10 * (delta - 1)) + from
end

return EaseInExpo
