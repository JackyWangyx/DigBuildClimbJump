local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local RewardUtil = require(game.ServerScriptService.ScriptAlias.RewardUtil)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local Define = require(game.ReplicatedStorage.Define)

local AccountRequest = nil

local LuckyWheel = {}

local DataTemplate = {
	LuckyWheel = {
		RemainCount = 1,
	}
}

function LuckyWheel:Init()
	AccountRequest = NetServer:RequireModule("Account")
end

function LoadInfo(player)
	local saveInfo = PlayerPrefs:GetModule(player, "LuckyWheel")
	return saveInfo
end

function LuckyWheel:GetCount(player)
	local saveInfo = LoadInfo(player)
	return saveInfo.RemainCount or 0
end

function LuckyWheel:GetList(player)
	local saveInfo = LoadInfo(player)
	local dataList = ConfigManager:GetDataList("LuckyWheel")
	return {
		RemainCount = saveInfo.RemainCount or 0,
		RewardList = dataList,
	}
end

function LuckyWheel:GetRemainCount(player)
	local saveInfo = LoadInfo(player)
	return saveInfo.RemainCount or 0
end

function LuckyWheel:Buy(player, param)
	local saveInfo = LoadInfo(player)
	local value = param.Value
	if not saveInfo.RemainCount then
		saveInfo.RemainCount = value
	else
		saveInfo.RemainCount = saveInfo.RemainCount + value
	end
	
	AnalyticsManager:EarnCurrency(player, AnalyticsManager.CurrencyType.LuckyWheel, value)
	
	return true
end

function LuckyWheel:Spin(player)
	local saveInfo = LoadInfo(player)
	if not saveInfo.RemainCount or saveInfo.RemainCount <= 0 then
		return {
			Success = false,
			Message = Define.Message.LuckyWheelNotEnough,
			RewardIndex = 1,
			RewardData = nil,
		}
	end
	
	local dataList = ConfigManager:GetDataList("LuckyWheel")
	local randData = Util:ListRandomWeight(dataList)
	local index = Util:ListIndexOf(dataList, randData)
	
	return {
		Success = true,
		Message = "",
		RewardIndex = index,
		RewardData = randData,
	}
end

function LuckyWheel:GetReward(player, param)
	local rewardIndex = param.RewardIndex
	
	local saveInfo = LoadInfo(player)
	
	saveInfo.RemainCount = saveInfo.RemainCount - 1
	if saveInfo.RemainCount < 0 then
		saveInfo.RemainCount = 0
	end

	local rewardData = ConfigManager:GetData("LuckyWheel", rewardIndex)
	RewardUtil:GetReward(player, rewardData.RewardType, rewardData.RewardID, rewardData.RewardCount)
	
	AnalyticsManager:Event(player, AnalyticsManager.Define.LuckyWheel)
	AnalyticsManager:SpendCurrency(player, AnalyticsManager.CurrencyType.LuckyWheel, 1)
	
	return true
end

return LuckyWheel
