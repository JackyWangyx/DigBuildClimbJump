local EaseInCirc = {}

function EaseInCirc:Ease(from, to, delta)
	to = to - from
	local result = -to * (math.sqrt(1 - delta * delta) - 1) + from
	return result
end

return EaseInCirc
