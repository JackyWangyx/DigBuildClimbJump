local EaseInQuad = {}

function EaseInQuad:Ease(from, to, delta)
	local range = to - from
	local result = range * delta * delta + from
	return result
end

return EaseInQuad
