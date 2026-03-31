local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)

local RewardUtil = require(game.ServerScriptService.ScriptAlias.RewardUtil)

local Define = require(game.ReplicatedStorage.Define)

local Reward = {}

function Reward:Init()
	
end

--------------------------------------------------------------------
-- 特殊
function Reward:GetNewbiePack(player)
	return 	Reward:GetRewardPackage(player, {
		PackageID = Define.Game.NewbiePackageID
	})
end

function Reward:GetLikePack(player)
	return 	Reward:GetRewardPackage(player, {
		PackageID = Define.Game.LikePackageID
	})
end

--------------------------------------------------------------------
-- 通用

function Reward:GetReward(player, param)
	local success, result = pcall(function()
		local rewardType = param.RewardType
		local rewardID = param.RewardID
		local rewardCount = param.RewardCount
		RewardUtil:GetReward(player, rewardType, rewardID, rewardCount)
		return nil
	end)
	
	if success then
		return {
			Success = true,
			Message = "Success",
			RewardList = {}
		}
	else
		return {
			Success = false,
			Message = "Get Fail : "..result,
			RewardList = {},
		}
	end
end

function Reward:GetRewardPackage(player, param)
	local success, result = pcall(function()
		local packageID = param.PackageID
		local rewardDataList = ConfigManager:SearchAllData("RewardPackage", "PackageID", packageID)
		RewardUtil:GetRewardList(player, rewardDataList)
		return rewardDataList
	end)
	
	if success then
		return {
			Success = true,
			Message = "Success",
			RewardList = result
		}
	else
		return {
			Success = false,
			Message = "Get Fail : "..result,
			RewardList = {},
		}
	end
end

return Reward
