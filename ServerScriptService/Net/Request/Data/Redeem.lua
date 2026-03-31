local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local TimeUtil = require(game.ReplicatedStorage.ScriptAlias.TimeUtil)
local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)

local RewardUtil = require(game.ServerScriptService.ScriptAlias.RewardUtil)
local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)

local Define = require(game.ReplicatedStorage.Define)

local Redeem = {}

local DataTemplate = {
	Redeem = {
		{
			RedeemCode = "HelloWorld",
			LastTime = "123",
			Count = 0,
		}
	}
}

function LoadInfo(player)
	local saveInfo = PlayerPrefs:GetModule(player, "Redeem")
	return saveInfo
end

function Redeem:GetReward(player, param)
	local redeemCode = param.RedeemCode
	local data = ConfigManager:SearchData("Redeem", "RedeemCode", redeemCode)
	if not data then
		return {
			Success = false,
			Message = Define.Message.RedeemNotExist,
		}
	end
	
	local saveInfo = LoadInfo(player)
	local info = Util:ListFind(saveInfo, function(i)
		return i.RedeemCode == redeemCode
	end)
	
	if info and info.Count >= data.Limit then
		return {
			Success = false,
			Message = Define.Message.RedeemFail,
		}
	end
	
	if info then
		info.Count = info.Count + 1
		info.LastTime = TimeUtil:GetNow()
	else
		info = {
			RedeemCode = redeemCode,
			LastTime = TimeUtil:GetNow(),
			Count = 1,
		}
		
		table.insert(saveInfo, info)
	end

	local rewardType = data.RewardType
	local rewardID = data.RewardID
	local rewardCount = data.RewardCount
	RewardUtil:GetReward(player, rewardType, rewardID, rewardCount)
	local rewardList = {}
	if rewardType == "Package" then
		rewardList = ConfigManager:SearchAllData("RewardPackage", "PackageID", rewardID)
	else
		table.insert(rewardList, data)
	end
	
	return {
		Success = true,
		Message = "Success",
		RewardList = rewardList
	}
end

return Redeem
