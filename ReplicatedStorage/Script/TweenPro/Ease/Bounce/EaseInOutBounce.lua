local EaseInOutBounce = {}

local EaseInBounce = require(script.Parent.EaseInBounce)
local EaseOutBounce = require(script.Parent.EaseOutBounce)

function EaseInOutBounce:Ease(from, to, delta)
	to -= from
	local d = 1
	if delta < d / 2 then
		local result = EaseInBounce:Ease(0, to, delta * 2) * 0.5 + from
		return result
	else
		local result = EaseOutBounce:Ease(0, to, delta * 2 - d) * 0.5 + to * 0.5 + from
		return result
	end
end

return EaseInOutBounce
