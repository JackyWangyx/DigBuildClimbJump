local EaseInOutCirc = {}

function EaseInOutCirc:Ease(from, to, delta)
	to = to - from
	delta = delta / 0.5

	local result
	if delta < 1 then
		result = -to / 2 * (math.sqrt(1 - delta * delta) - 1) + from
	else
		delta = delta - 2
		result = to / 2 * (math.sqrt(1 - delta * delta) + 1) + from
	end

	return result
end

return EaseInOutCirc
