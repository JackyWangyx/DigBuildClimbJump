local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local PlayerCache = require(game.ServerScriptService.ScriptAlias.PlayerCache)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local OfflineReward = {}

local DataTemplate = {
	Login = {
		LastOfflineTime = -1,
	}
}

function OfflineReward:Init()
	PlayerManager:HandlePlayerAddRemove(nil, function(player)
		OfflineReward:UpdateOfflieTime(player)
	end)
end

function LoadInfo(player)
	local saveInfo = PlayerPrefs:GetModule(player, "OfflineReward")
	return saveInfo
end

function OfflineReward:UpdateOfflieTime(player)
	local saveInfo = LoadInfo(player)
	saveInfo.LastOfflineTime = os.time()
	return true
end

local function GetRewardCoin(rebirthLevel, totalTime)
	local maxTime = 60 * 12
	if totalTime > maxTime then totalTime = maxTime end
	local result = ( rebirthLevel + 1 ) * ( ( totalTime * 60 ) ^ 0.6 )
	return result
end

function OfflineReward:GetInfo(player)
	local saveInfo = LoadInfo(player)
	local currentTime = PlayerCache:GetLoginTime(player)
	local offlineTime = saveInfo.LastOfflineTime
	local totalTime = 0
	if offlineTime ~= nil then
		local diffTime = currentTime - offlineTime
		if diffTime < 0 then diffTime = 0 end
		totalTime = math.round((diffTime) / 60)
	end
	
	local rebirthLevel = NetServer:RequireModule("Rebirth"):GetInfo(player).ID - 1
	local rewardCoin = GetRewardCoin(rebirthLevel, totalTime)
	local info = {
		Time = totalTime,
		RewardCoin = rewardCoin
	}
	
	return info
end 

function OfflineReward:GetReward(player)
	local saveInfo = LoadInfo(player)
	local info = OfflineReward:GetInfo(player)
	NetServer:RequireModule("Account"):AddCoin(player, { Value = info.RewardCoin })
	saveInfo.LastOfflineTime = os.time()
	return true
end

return OfflineReward
