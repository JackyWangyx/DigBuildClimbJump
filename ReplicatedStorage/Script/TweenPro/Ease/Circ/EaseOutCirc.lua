local EaseOutCirc = {}

function EaseOutCirc:Ease(from, to, delta)
	delta = delta - 1
	to = to - from
	local result = to * math.sqrt(1 - delta * delta) + from
	return result
end

return EaseOutCirc
