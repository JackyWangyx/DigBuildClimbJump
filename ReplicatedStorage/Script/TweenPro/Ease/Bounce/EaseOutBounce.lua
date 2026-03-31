local EaseOutBounce = {}

function EaseOutBounce:Ease(from, to, delta)
	to = to - from
	if delta < (1 / 2.75) then
		return to * (7.5625 * delta * delta) + from
	elseif delta < (2 / 2.75) then
		delta = delta - (1.5 / 2.75)
		return to * (7.5625 * delta * delta + 0.75) + from
	elseif delta < (2.5 / 2.75) then
		delta = delta - (2.25 / 2.75)
		return to * (7.5625 * delta * delta + 0.9375) + from
	else
		delta = delta - (2.625 / 2.75)
		local result = to * (7.5625 * delta * delta + 0.984375) + from
		return result
	end
end

return EaseOutBounce
