local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)

local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)
local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local PlayerProperty = require(game.ServerScriptService.ScriptAlias.PlayerProperty)

local Account = {}

function LoadInfo(player)
	local saveInfo = PlayerPrefs:GetModule(player, "Account")
	return saveInfo
end

local CurrencySystem = {}

local CurrencyDefine = {
	Coin = {
		Default     = 0,
		EventGet    = EventManager.Define.GetCoin,
		EventRefresh= EventManager.Define.RefreshCoin,
		RecordKey   = PlayerRecord.Define.TotalGetCoin,
		QuestEvent  = EventManager.Define.QuestGetCoin,
		Type        = AnalyticsManager.CurrencyType.Coin,
	},
	Wins = {
		Default     = 0,
		EventGet    = EventManager.Define.GetWins,
		EventRefresh= EventManager.Define.RefreshWins,
		RecordKey   = PlayerRecord.Define.TotalGetWins,
		QuestEvent  = EventManager.Define.QuestGetWins,
		Type        = AnalyticsManager.CurrencyType.Wins,
	},
	Power = {
		Default     = 0,
		EventGet    = EventManager.Define.GetPower,
		EventRefresh= EventManager.Define.RefreshPower,
		RecordKey   = PlayerRecord.Define.TotalGetPower,
		QuestEvent  = EventManager.Define.QuestGetPower,
		Type        = AnalyticsManager.CurrencyType.Power,
	},
}

----------------------------------------------------------------------------
-- 通用处理

function Account:Get(player, currencyName)
	local account = LoadInfo(player)
	local config = CurrencyDefine[currencyName]
	if not config then return 0 end

	local val = account[currencyName]
	if val == nil then
		val = config.Default
		account[currencyName] = val
	end
	return val
end

function Account:Modify(player, currencyName, delta, source)
	if delta == 0 then return true end

	local config = CurrencyDefine[currencyName]
	if not config then return false end

	local account = LoadInfo(player)
	local current = account[currencyName] or config.Default

	if delta < 0 and current < -delta then
		return false
	end

	current = current + delta
	account[currencyName] = current

	local absDelta = math.abs(delta)
	local isAdd = delta > 0

	EventManager:DispatchToClient(player, config.EventRefresh, current)

	if isAdd then
		if config.EventGet    then EventManager:DispatchToClient(player, config.EventGet, absDelta) end
		if config.RecordKey   then PlayerRecord:AddValue(player, config.RecordKey, absDelta) end
		if config.QuestEvent  then EventManager:Dispatch(config.QuestEvent, {Player = player, Value = absDelta}) end
		AnalyticsManager:EarnCurrency(player, config.Type, absDelta, source)
	else
		AnalyticsManager:SpendCurrency(player, config.Type, absDelta, source)
	end

	return true
end

----------------------------------------------------------------------------
-- Coin

function Account:GetCoin(player)    
	local result = Account:Get(player, "Coin") 
	return result
end

function Account:AddCoin(player, param)
	local result = Account:Modify(player, "Coin", param.Value, param.Source)
	return result
end

function Account:SpendCoin(player, param)
	local result = Account:Modify(player, "Coin", -param.Value, param.Source)
	return result
end

----------------------------------------------------------------------------
-- Wins

function Account:GetWins(player)    
	local result = Account:Get(player, "Wins") 
	return result
end

function Account:AddWins(player, param)
	local result = Account:Modify(player, "Wins", param.Value, param.Source)
	return result
end

function Account:SpendWins(player, param)
	local result = Account:Modify(player, "Wins", -param.Value, param.Source)
	return result
end

----------------------------------------------------------------------------
-- Power

function Account:GetPower(player)    
	local result = Account:Get(player, "Power") 
	return result
end

function Account:AddPower(player, param)
	local result = Account:Modify(player, "Power", param.Value, param.Source)
	return result
end

function Account:SpendPower(player, param)
	local result = Account:Modify(player, "Power", -param.Value, param.Source)
	return result
end

return Account