local EaseInOutExpo = {}

function EaseInOutExpo:Ease(from, to, delta)
	delta = delta / 0.5
	to = to - from

	if delta < 1 then
		return to / 2 * 2^(10 * (delta - 1)) + from
	else
		delta = delta - 1
		return to / 2 * (-2^(-10 * delta) + 2) + from
	end
end

return EaseInOutExpo
