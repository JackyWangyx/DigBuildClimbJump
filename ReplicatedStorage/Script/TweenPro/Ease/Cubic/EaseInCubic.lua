local EaseInCubic = {}

function EaseInCubic:Ease(from, to, delta)
	to = to - from
	local result = to * delta * delta * delta + from
	return result
end

return EaseInCubic
