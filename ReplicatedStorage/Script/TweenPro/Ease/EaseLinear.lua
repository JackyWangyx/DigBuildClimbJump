local EaseLinear = {}

function EaseLinear:Ease(from, to, delta)
	local result = from + (to - from) * delta
	return result
end

return EaseLinear
