local EaseInOutQuart = {}

function EaseInOutQuart:Ease(from, to, delta)
	delta = delta / 0.5
	local range = to - from

	if delta < 1 then
		return range / 2 * delta * delta * delta * delta + from
	else
		delta = delta - 2
		return -range / 2 * (delta * delta * delta * delta - 2) + from
	end
end

return EaseInOutQuart
