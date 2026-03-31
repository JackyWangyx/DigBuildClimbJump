local EaseStep = {}

function EaseStep:Ease(from, to, delta, strength)
	local count = math.floor(2 + (10 - 2) * strength + 0.5)
	local step = 1 / count
	local current = math.floor(delta / step)
	local result = current * step
	return result
end

return EaseStep
