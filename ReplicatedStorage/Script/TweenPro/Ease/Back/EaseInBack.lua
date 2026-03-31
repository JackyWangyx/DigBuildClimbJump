local EaseInBack = {}

function EaseInBack:Ease(from, to, delta)
	to = to - from
	local s = 1.70158
	local result = to * delta * delta * ((s + 1) * delta - s) + from
	return result
end

return EaseInBack
