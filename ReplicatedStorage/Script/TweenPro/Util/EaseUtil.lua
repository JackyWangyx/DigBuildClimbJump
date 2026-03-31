local EaseUtil = {}

local EaseCache = {}

local function Cache()
	local easeList = script.Parent.Parent.Ease:GetDescendants()
	for _, child in ipairs(easeList) do
		if child:IsA("ModuleScript") then
			local easeType = string.gsub(child.Name, "Ease", "")
			EaseCache[easeType] = require(child).Ease
		end	
	end
end

function EaseUtil:GetEaseFunction(easeType)
	local func = EaseCache[easeType]
	if not func then 
		Cache()
		func = EaseCache[easeType]
	end
	return func
end

function EaseUtil:Ease(easeType, from, to, delta, strength)
	local easeFunc = EaseUtil:GetEaseFunction(easeType)
	strength = strength or 1
	local result = easeFunc(from, to, delta, strength)
	return result
end

return EaseUtil
