local EaseInBounce = {}

local EaseOutBounce = require(script.Parent.EaseOutBounce)

function EaseInBounce:Ease(from, to, delta)
	to -= from
	local result =  to - EaseOutBounce:Ease(0, to, 1 - delta) + from
	return result
end

return EaseInBounce
