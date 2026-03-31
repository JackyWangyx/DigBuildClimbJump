local AnalyticsService = game:GetService("AnalyticsService")
local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local RunService = game:GetService("RunService")

local TaskThrottleScheduler = require(game.ReplicatedStorage.ScriptAlias.TaskThrottleScheduler)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local AnalyticsManager = {}

AnalyticsManager.Define = require(game.ReplicatedStorage.Define).Analytics

local EnumKeys = Enum.AnalyticsCustomFieldKeys
local IsInit = false

local TaskleScheduler = TaskThrottleScheduler.new(120, 0.1, 1, 1)

function AnalyticsManager:Init()
	local isClient = RunService:IsClient()
	if isClient then
		return
	end
	
	IsInit = true
	
	UpdatorManager:Heartbeat(function(deltaTime)
		AnalyticsManager:Update(deltaTime)
	end)
end

-- Event

function AnalyticsManager:Event(player, eventName, ...)
	local args = { ... }
	local suucess, result = pcall(function()
		if not IsInit then return end
		if #args % 2 ~= 0 then
			warn("Param Error")
			return
		end

		local value = 1
		local idx = 1
		local fields = {}
		for i = 1, #args, 2 do
			if idx > 3 then break end
			local key = args[i]
			local value = args[i + 1]
			local fieldName = ("CustomField0%d"):format(idx)
			fields[EnumKeys[fieldName].Name] = tostring(key) .. "=" .. tostring(value)
			idx += 1
		end

		AnalyticsService:LogCustomEvent(player, eventName, value, fields)
	end)
end

-- Funnel
function AnalyticsManager:Funnel(player, funnelName, stepIndex, stepName)
	local suucess, result = pcall(function()
		AnalyticsService:LogFunnelStepEvent(
			player,
			funnelName, 
			player.UserId,
			stepIndex,
			stepName
		)
	end)
end

-- Economy

AnalyticsManager.CurrencyType = {
	Coin = "Coin",
	Wins = "Wins",
	Power = "Power",
	LuckyWheel = "LuckyWheel",
}

AnalyticsManager.CurrencySourceType = {
	IAP = Enum.AnalyticsEconomyTransactionType.IAP.Name,
	Shop = Enum.AnalyticsEconomyTransactionType.Shop.Name,
	Gameplay = Enum.AnalyticsEconomyTransactionType.Gameplay.Name,
	Sign = Enum.AnalyticsEconomyTransactionType.TimedReward.Name
}

local SendCuuencyInterval = 5
local SendCuuencyTimer = 0

local SendCuuencyEventCache = {}

local EventsPerMinute = 0
local ResetTimer = 0
local MaxEventsPerMinute = 80

function AnalyticsManager:Update(deltaTime)
	ResetTimer += deltaTime
	if ResetTimer >= 60 then
		EventsPerMinute = 0
		ResetTimer = 0
	end

	SendCuuencyTimer += deltaTime
	if SendCuuencyTimer < SendCuuencyInterval then return end
	SendCuuencyTimer = 0

	if #SendCuuencyEventCache > 0 and EventsPerMinute < MaxEventsPerMinute then
		local event = table.remove(SendCuuencyEventCache, 1)
		local success = pcall(function()
			AnalyticsService:LogEconomyEvent(
				event.Player,
				event.OperateType,
				event.CurrencyType,
				event.Value,
				AnalyticsManager:GetBlannce(event.Player, event.CurrencyType),
				event.SourceType,
				event.Sku
			)
		end)

		if success then
			EventsPerMinute += 1
		end
	end
end

function AnalyticsManager:GetBlannce(player, currencyType)
	if currencyType == AnalyticsManager.CurrencyType.Coin then
		local account = require(game.ServerScriptService.ScriptAlias.Account)
		return account:GetCoin(player)
	elseif currencyType == AnalyticsManager.CurrencyType.Power then
		local training = require(game.ServerScriptService.ScriptAlias.Training)
		return training:GetPower(player)
	elseif currencyType == AnalyticsManager.CurrencyType.Spin then
		local luckyWheel = require(game.ServerScriptService.ScriptAlias.LuckyWheel)
		return luckyWheel:GetCount(player)
	end

	return 0
end

function AnalyticsManager:AddCurrencyEvent(player, operateType, currencyType, value, sourceType, sku)
	sourceType = sourceType or AnalyticsManager.CurrencySourceType.Gameplay
	local event = Util:ListFind(SendCuuencyEventCache, function(e)
		return e.Player == player
			and e.OperateType == operateType
			and e.CurrencyType == currencyType
			and e.SourceType == sourceType
			and e.Sku == sku
	end)
	
	if not event then
		event = {
			Player = player,
			OperateType = operateType,
			CurrencyType = currencyType,
			Value = value,
			SourceType = sourceType,
			Sku = sku,
		}
		
		table.insert(SendCuuencyEventCache, event)
	else
		event.Value += value
	end
end

function AnalyticsManager:EarnCurrency(player, currencyType, value, sourceType, sku)
	--AnalyticsManager:AddCurrencyEvent(player, Enum.AnalyticsEconomyFlowType.Source, currencyType, value, sourceType, sku)
end


function AnalyticsManager:SpendCurrency(player, currencyType, value, sourceType, sku)
	--AnalyticsManager:AddCurrencyEvent(player, Enum.AnalyticsEconomyFlowType.Sink, currencyType, value, sourceType, sku)
end

return AnalyticsManager
