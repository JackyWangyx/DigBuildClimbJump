local EaseInQuint = {}

function EaseInQuint:Ease(from, to, delta)
	local range = to - from
	return range * delta * delta * delta * delta * delta + from
end

return EaseInQuint
