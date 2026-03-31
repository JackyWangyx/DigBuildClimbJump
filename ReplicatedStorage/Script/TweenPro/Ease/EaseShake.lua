local EaseShake = {}

function EaseShake:Ease(from, to, delta, strength, damping)
	if strength <= 0 then
		return from
	end

	damping = damping or 3
	local wave = math.cos(delta * math.pi * 2 * strength)
	local decay = math.exp(-damping * delta)
	local amplitude = (to - from)
	return from + amplitude * wave * decay
end

return EaseShake