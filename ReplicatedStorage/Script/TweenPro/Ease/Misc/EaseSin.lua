local EaseSin = {}

function EaseSin:Ease(from, to, delta, strength)
	local count = math.floor(1 + (20 - 1) * strength + 0.5)
	local range = to - from
	local result = math.sin(math.pi * delta * count) * range
	return result
end

return EaseSin
