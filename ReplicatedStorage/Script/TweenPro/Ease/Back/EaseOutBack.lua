local EaseOutBack = {}

function EaseOutBack:Ease(from, to, delta)
	local s = 1.70158
	to = to - from
	delta = (delta / 1) - 1

	local result = to * (delta * delta * ((s + 1) * delta + s) + 1) + from
	return result
end

return EaseOutBack
