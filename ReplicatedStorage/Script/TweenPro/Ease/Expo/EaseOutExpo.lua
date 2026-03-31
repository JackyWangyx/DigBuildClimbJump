local EaseOutExpo = {}

function EaseOutExpo:Ease(from, to, delta)
	to = to - from
	return to * (1 - 2^(-10 * delta)) + from
end

return EaseOutExpo
