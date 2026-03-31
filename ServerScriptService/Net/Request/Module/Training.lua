local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)

local PlayerProperty = require(game.ServerScriptService.ScriptAlias.PlayerProperty)
local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local AccountRequest = require(game.ServerScriptService.ScriptAlias.Account)

local Training = {}

function Training:Start(player, param)
	local index = param.Index
	local trainingHandler = require(game.ServerScriptService.ScriptAlias.TrainingHandler)
	local result = trainingHandler:Start(player, index)
	return result
end

function Training:End(player, param)
	local trainingHandler = require(game.ServerScriptService.ScriptAlias.TrainingHandler)
	local result = trainingHandler:End(player)
	return result
end

-- 仅训练值，不包含基础值
function Training:GetPower(player)
	local baseProperty = PlayerProperty:GetPlayerProperty(player)
	local power = AccountRequest:GetPower(player)
	return power
end

function Training:AddPower(player, param)
	local value = param.Value
	local currentValue = Training:GetPower(player)
	local targetValue = currentValue + value
	
	AccountRequest:AddPower(player, param)
	PlayerRecord:SetMaxValue(player, PlayerRecord.Define.MaxTrainingPower, targetValue)

	return true
end

function Training:SpendPower(player, param)
	local value = param.Value
	local result = AccountRequest:SpendPower(player, param)
	return result
end

return Training
