local EaseCos = {}

function EaseCos:Ease(from, to, delta, strength)
	local count = math.floor(1 + (20 - 1) * strength + 0.5)
	local range = to - from
	local result = from + math.cos(math.pi * (delta * count + 0.5)) * range
	return result
end

return EaseCos
