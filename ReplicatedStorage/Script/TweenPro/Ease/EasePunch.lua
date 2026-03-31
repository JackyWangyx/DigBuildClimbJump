local EasePunch = {}

function EasePunch:Ease(from, to, delta)
	local amplitude = to - from
	local s = 9.0
	if math.abs(delta) < 1e-6 then
		return 0
	end

	if math.abs(delta - 1) < 1e-6 then
		return 0
	end

	local period = 1 * 0.3
	s = period / (2 * math.pi) * math.asin(0);
	local result = amplitude * math.pow(2, -10 * delta) * math.sin((delta * 1 - s) * (2 * math.pi) / period)
	return result
end

return EasePunch
