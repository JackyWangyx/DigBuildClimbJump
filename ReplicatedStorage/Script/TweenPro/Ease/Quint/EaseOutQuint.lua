local EaseOutQuint = {}

function EaseOutQuint:Ease(from, to, delta)
	delta = delta - 1
	local range = to - from
	return range * (delta * delta * delta * delta * delta + 1) + from
end

return EaseOutQuint
