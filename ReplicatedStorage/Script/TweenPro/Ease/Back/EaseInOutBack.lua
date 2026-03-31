local EaseInOutBack = {}

function EaseInOutBack:Ease(from, to, delta)
	local s = 1.70158
	to = to - from
	delta = delta / 0.5

	if delta < 1 then
		s = s * 1.525
		local result = to / 2 * (delta * delta * (((s + 1) * delta) - s)) + from
		return result
	else
		delta = delta - 2
		s = s * 1.525
		local result = to / 2 * ((delta * delta * (((s + 1) * delta) + s)) + 2) + from
		return result
	end
end

return EaseInOutBack
