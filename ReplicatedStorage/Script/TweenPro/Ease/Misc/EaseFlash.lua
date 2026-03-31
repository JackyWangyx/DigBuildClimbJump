local EaseFlash = {}

function EaseFlash:Ease(from, to, delta, strength)
	local count = math.floor(1 + (5 - 1) * strength + 0.5) * 2 + 1
	local step = 1 / count
	local current = math.floor(delta / step)
	if current % 2 == 0 then
		return 0
	else
		return 1
	end
end

return EaseFlash
