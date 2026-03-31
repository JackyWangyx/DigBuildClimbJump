local EaseInOutQuad = {}

function EaseInOutQuad:Ease(from, to, delta)
	delta = delta / 0.5
	local range = to - from

	if delta < 1 then
		local result = range / 2 * delta * delta + from
		return result
	else
		delta = delta - 1
		local result = -range / 2 * (delta * (delta - 2) - 1) + from
		return result
	end
end

return EaseInOutQuad
