local ConditionChecker = {}

local ParamTemplate = {
	Type = "",
	RequireValue = 2,
	Param = {
		Param1 = 1,
		Param2 = 2,
	},
}

local ResultTemplate = {
	Success = true,
	CurrentValue = 1,
	RequireValue = 2,
}

ConditionChecker.Define = require(game.ReplicatedStorage.Define).Condition

local CheckerCache = {}

function ConditionChecker:Check(player, checkerType, requireValue, param)
	local checkInfo = ConditionChecker:GetCheckInfo(player, checkerType, requireValue, param)
	return checkInfo.Success
end

function ConditionChecker:GetCheckInfo(player, checkerType, requireValue, param)
	local checker = ConditionChecker:CetChecker(checkerType)
	if not checker then
		return false
	end
	local result = checker:Check(player, requireValue, param)
	return result
end

function ConditionChecker:CetChecker(checkerType)
	local checkerName = checkerType.."Checker"
	local checker = CheckerCache[checkerName]
	if not checker then
		local checkerScript = script.Parent.Checker:FindFirstChild(checkerName)
		if not checkerScript then
			warn("[Checker] Not Found : ", checkerType)
			return nil
		end
		checker = require(checkerScript)
		CheckerCache[checkerType] = checker
		return checker
	else
		return checker
	end
end

return ConditionChecker
