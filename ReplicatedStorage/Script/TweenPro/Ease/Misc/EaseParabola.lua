local EaseDash = {}

function EaseDash:Ease(from, to, delta, strength)
	strength = strength or 2.5 
	local range = to - from
	local half = 0.5
	local t = (delta / half) - 1
	local result = 1 - math.abs(t) ^ strength
	return from + range * result
end

return EaseDash
