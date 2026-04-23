local RunService = game:GetService("RunService")

local NetClient = nil
local ConditionChecker = nil

local ConditionUtil = {}

ConditionUtil.Define = require(game.ReplicatedStorage.Define).Condition

function ConditionUtil:Check(player, checkerType, requireValue, param)
	local checkInfo = ConditionUtil:GetCheckInfo(player, checkerType, requireValue, param)
	return checkInfo.Success
end

function ConditionUtil:GetCheckInfo(player, checkerType, requireValue, param)
	if RunService:IsClient() then
		if not player or typeof(player) == "string" then
			param = requireValue
			requireValue = checkerType
			checkerType = player
		end

		if not NetClient then
			NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
		end

		local result = NetClient:RequestWait("Game", "CheckCondition", {
			Type = checkerType,
			RequireValue = requireValue,
			Param = param,
		})

		return result
	else
		if not ConditionChecker then
			ConditionChecker = require(game.ServerScriptService.ScriptAlias.ConditionChecker)
		end

		local result = ConditionChecker:GetCheckInfo(player, checkerType, requireValue, param)
		return result
	end
end

return ConditionUtil
