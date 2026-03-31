local EaseOutCubic = {}

function EaseOutCubic:Ease(from, to, delta)
	delta = delta - 1
	to = to - from
	return to * (delta * delta * delta + 1) + from
end

return EaseOutCubic
