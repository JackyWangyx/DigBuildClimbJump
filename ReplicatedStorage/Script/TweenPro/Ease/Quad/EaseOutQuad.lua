local EaseOutQuad = {}

function EaseOutQuad:Ease(from, to, delta)
	local range = to - from
	local result = -range * delta * (delta - 2) + from
	return result
end

return EaseOutQuad
