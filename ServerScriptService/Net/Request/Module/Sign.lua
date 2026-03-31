local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local TimeUtil = require(game.ReplicatedStorage.ScriptAlias.TimeUtil)
local ActivityUtil = require(game.ReplicatedStorage.ScriptAlias.ActivityUtil)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local RewardUtil = require(game.ServerScriptService.ScriptAlias.RewardUtil)
local PlayerCache = require(game.ServerScriptService.ScriptAlias.PlayerCache)

local Define = require(game.ReplicatedStorage.Define)

local SaveInfoSample = {
	Daily = {
		["Key"] = {
			FirstLoginDate = nil,
			LastGetRewardDate = nil,
		}
	}
}

local Sign = {}

function LoadInfo(player)
	local saveInfo = PlayerPrefs:GetModule(player, "Sign")
	return saveInfo
end

function GetDailyInfo(player, key)
	local info = LoadInfo(player)
	if info.Daily == nil then
		info.Daily = {}
	end

	local dailyInfo = info.Daily[key]
	if dailyInfo == nil then
		dailyInfo = {
			FirstLoginDate = nil, 					-- 初次进入游戏时间
			LastGetRewardDate = nil,  				-- 上次领取奖励的日期
		}

		info.Daily[key] = dailyInfo
	end

	if Define.Test.EnableSignLoginDate then
		dailyInfo.FirstLoginDate = TimeUtil:GetNow()
		local date = dailyInfo.FirstLoginDate
		date.year = Define.Test.LoginDate.SignYear
		date.month =  Define.Test.LoginDate.SignMonth
		date.day = Define.Test.LoginDate.SignDay
		date.hour = Define.Test.LoginDate.SignHour
		date.min = Define.Test.LoginDate.SignMin
		date.sec = Define.Test.LoginDate.SignSec
	end

	return dailyInfo
end

----------------------------------------------------------------------------------------------------------

-- Daily

function Sign:GetDailyList(player, param)
	local key = param.Key
	local isActivity = param.IsActivity or false
	local info = GetDailyInfo(player, key)
	local dataList = ConfigManager:GetDataList(key)
	local result = {}
	local now = TimeUtil:GetNow()
	
	local isComplete = Sign:CheckDailyComplete(player, param)
	if isActivity then
		local activityKey = param.ActivityKey
		local activityData = ActivityUtil:GetData(activityKey)
		local inProcess = ActivityUtil:Check(activityKey)
		if not inProcess then
			now = nil
		else
			if info.FirstLoginDate == nil then
				info.FirstLoginDate = now
			end
		end
	else
		if info.FirstLoginDate == nil then
			info.FirstLoginDate = now
		end
		
		if isComplete and TimeUtil:IsDifferentDate(info.LastGetRewardDate, now) then
			--print("Daily Reset")
			info.FirstLoginDate = now
			info.LastGetRewardDate = nil
		end	
	end

	local signDayCount = TimeUtil:DaysBetween(info.FirstLoginDate, info.LastGetRewardDate)
	local currentDayCount = TimeUtil:DaysBetween(info.FirstLoginDate, now)
	
	for _, data in ipairs(dataList) do
		local signData = Util:TableCopy(data)
		-- 已领取 : 上次领取日期间隔，大于等于当前配置所需天数
		local isGetReward = signDayCount >= data.RequireDay
		-- 可领取 : 未领取，且当前日期间隔，大于等于当前配置所需天数	
		local canGetReward = (not isGetReward) and currentDayCount >= data.RequireDay	
		signData.CanGetReward = canGetReward
		signData.IsGetReward = isGetReward
		table.insert(result, signData)
	end
	
	return result
end

function Sign:GetDailyReward(player, param)
	local key = param.Key
	local id = param.ID
	local info = GetDailyInfo(player, key)
	local dataList = ConfigManager:GetDataList(key)
	local count = #dataList
	local now = TimeUtil:GetNow() 

	local rewardList = {}
	local signDayCount = TimeUtil:DaysBetween(info.FirstLoginDate, info.LastGetRewardDate)
	for index = 1, count do
		local data = dataList[index]	
		local isGetReward = signDayCount >= data.RequireDay
		local currentDayCount = TimeUtil:DaysBetween(info.FirstLoginDate, now)
		local canGetReward = (not isGetReward) and currentDayCount >= data.RequireDay
		if canGetReward then
			local rewardType = data.RewardType
			local rewardID = data.RewardID
			local rewardCount = data.RewardCount
			RewardUtil:GetReward(player, rewardType, rewardID, rewardCount)
			table.insert(rewardList, data)
		end
	end

	info.LastGetRewardDate = now
	return rewardList
end

function Sign:CheckDailyComplete(player, param)
	local key = param.Key
	local info = GetDailyInfo(player, key)
	local dataList = ConfigManager:GetDataList(key)
	local maxRequireDay = dataList[#dataList].RequireDay
	local signDayCount = TimeUtil:DaysBetween(info.FirstLoginDate, info.LastGetRewardDate)
	return signDayCount >= maxRequireDay
end

function Sign:CheckCanSignDaily(player, param)
	local key = param.Key
	local isActivity = param.IsActivity or false
	local info = GetDailyInfo(player, key)
	local dataList = ConfigManager:GetDataList(key)
	local now = TimeUtil:GetNow()
	local signDayCount = TimeUtil:DaysBetween(info.FirstLoginDate, info.LastGetRewardDate)
	for _, data in pairs(dataList) do
		local isGetReward = signDayCount >= data.RequireDay
		local currentDayCount = TimeUtil:DaysBetween(info.FirstLoginDate, now)
		local canGetReward = (not isGetReward) and currentDayCount >= data.RequireDay
		if canGetReward then
			return true
		end
	end

	return false
end

function Sign:GetNextDailyReward(player, param)
	local key = param.Key
	local info = GetDailyInfo(player, key)
	local dataList = ConfigManager:GetDataList(key)
	local now = TimeUtil:GetNow()

	local currentDayCount = TimeUtil:DaysBetween(info.FirstLoginDate, now)
	
	local result = {}
	local find = false
	for _, data in ipairs(dataList) do
		if currentDayCount < data.RequireDay then
			table.insert(result, data)
			find = true
			break
		end
	end

	if not find then
		table.insert(result, dataList[1])
	end
	return result
end

function Sign:GetAllDailyReward(player, param)
	local key = param.Key
	local info = GetDailyInfo(player, key)
	local dataList = ConfigManager:GetDataList(key)
	local count = #dataList
	local now = TimeUtil:GetNow() 

	local rewardList = {}
	local signDayCount = TimeUtil:DaysBetween(info.FirstLoginDate, info.LastGetRewardDate)
	local completeDate = TimeUtil:AddDays(info.FirstLoginDate, count + 1)
	
	for index = 1, count do
		local data = dataList[index]	
		local isGetReward = signDayCount >= data.RequireDay
		local currentDayCount = TimeUtil:DaysBetween(info.FirstLoginDate, completeDate)
		local canGetReward = (not isGetReward) and currentDayCount >= data.RequireDay
		if canGetReward then
			local rewardType = data.RewardType
			local rewardID = data.RewardID
			local rewardCount = data.RewardCount
			RewardUtil:GetReward(player, rewardType, rewardID, rewardCount)
			table.insert(rewardList, data)
		end
	end

	info.LastGetRewardDate = completeDate

	return rewardList
end

----------------------------------------------------------------------------------------------------------

-- Online

function Sign:GetOnlineList(player, param)
	local key = param.Key
	local dataList = ConfigManager:GetDataList(key)
	local result = {}
	local now = os.time()
	local loginTime = PlayerCache:GetLoginTime(player)
	local lastGetDailyRewardTime = PlayerCache:GetValue(player, "LastGetDailyRewardTime"..key)
	if not lastGetDailyRewardTime then lastGetDailyRewardTime = loginTime end	
	for _, data in ipairs(dataList) do
		local signData = Util:TableCopy(data)
		local lastGetRewardDuration = lastGetDailyRewardTime - loginTime
		local isGetReward = lastGetRewardDuration >= data.RequireTime
		local currentDuration = now - loginTime
		local canGetReward = (not isGetReward) and currentDuration >= data.RequireTime	
		signData.CanGetReward = canGetReward
		signData.IsGetReward = isGetReward
		signData.LoginTime = loginTime
		table.insert(result, signData)
	end
	return result
end

function Sign:GetOnlineReward(player, param)
	local key = param.Key
	local id = param.ID
	local dataList = ConfigManager:GetDataList(key)
	local count = #dataList
	local now = os.time()
	local loginTime = PlayerCache:GetLoginTime(player)
	local lastGetDailyRewardTime = PlayerCache:GetValue(player, "LastGetDailyRewardTime"..key)
	if not lastGetDailyRewardTime then lastGetDailyRewardTime = loginTime end

	local rewardList = {}
	for index = 1, count do
		local data = dataList[index]
		local lastGetRewardDuration = lastGetDailyRewardTime - loginTime
		local isGetReward = lastGetRewardDuration >= data.RequireTime
		local currentDuration = now - loginTime
		local canGetReward = (not isGetReward) and currentDuration >= data.RequireTime	
		if canGetReward then
			local rewardType = data.RewardType
			local rewardID = data.RewardID
			local rewardCount = data.RewardCount
			RewardUtil:GetReward(player, rewardType, rewardID, rewardCount)
			table.insert(rewardList, data)
		end
	end

	PlayerCache:SetValue(player, "LastGetDailyRewardTime"..key, now)
	return rewardList
end

function Sign:GetAllOnlineReward(player, param)
	local key = param.Key
	local dataList = ConfigManager:GetDataList(key)
	local now = os.time()

	local rewardList = {}
	for _, data in ipairs(dataList) do
		local rewardType = data.RewardType
		local rewardID = data.RewardID
		local rewardCount = data.RewardCount
		RewardUtil:GetReward(player, rewardType, rewardID, rewardCount)
		table.insert(rewardList, data)
	end

	PlayerCache:SetValue(player, "LastGetDailyRewardTime"..key, now + 999999999999)
	return rewardList
end

function Sign:CheckCanSignOnline(player, param)
	local key = param.Key
	local dataList = ConfigManager:GetDataList(key)
	local result = {}
	local now = os.time()
	local loginTime = PlayerCache:GetLoginTime(player)
	local lastGetDailyRewardTime = PlayerCache:GetValue(player, "LastGetDailyRewardTime"..key)
	if not lastGetDailyRewardTime then lastGetDailyRewardTime = loginTime end	
	for _, data in pairs(dataList) do
		local signData = Util:TableCopy(data)
		local lastGetRewardDuration = lastGetDailyRewardTime - loginTime
		local isGetReward = lastGetRewardDuration >= data.RequireTime
		local currentDuration = now - loginTime
		local canGetReward = (not isGetReward) and currentDuration >= data.RequireTime	
		if canGetReward then
			return true
		end
	end
	return false
end

function Sign:CheckOnlineComplete(player, param)
	local key = param.Key
	local dataList = ConfigManager:GetDataList(key)
	local loginTime = PlayerCache:GetLoginTime(player)
	local lastGetDailyRewardTime = PlayerCache:GetValue(player, "LastGetDailyRewardTime"..key)
	if not lastGetDailyRewardTime then return false end
	local maxRequireTime = dataList[#dataList].RequireTime
	local isComplete = lastGetDailyRewardTime - loginTime >= maxRequireTime
	return isComplete
end

return Sign