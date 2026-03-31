local EaseSpring = {}

function EaseSpring:Ease(from, to, delta)
	local delta = (math.sin(delta * math.pi * (0.2 + 2.5 * delta * delta * delta)) * math.pow(1 - delta, 2.2) + delta) * (1 + (1.2 * (1 - delta)))
	local result = from + (to - from) * delta
	return result
end

return EaseSpring
