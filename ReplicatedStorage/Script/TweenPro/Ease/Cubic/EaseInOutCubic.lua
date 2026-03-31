local EaseInOutCubic = {}

function EaseInOutCubic:Ease(from, to, delta)
	delta = delta / 0.5
	to = to - from

	if delta < 1 then
		return to / 2 * delta * delta * delta + from
	else
		delta = delta - 2
		return to / 2 * (delta * delta * delta + 2) + from
	end
end

return EaseInOutCubic
