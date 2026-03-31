local EaseOutQuart = {}

function EaseOutQuart:Ease(from, to, delta)
	delta = delta - 1
	local range = to - from
	return -range * (delta * delta * delta * delta - 1) + from
end

return EaseOutQuart
