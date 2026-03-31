local TimeUtil = require(game.ReplicatedStorage.ScriptAlias.TimeUtil)

local Define = require(game.ReplicatedStorage.Define)

local ActivityUtil = {}

function ActivityUtil:GetData(activityKey)
	if not activityKey then
		return nil
	end
	
	local data = Define.Activity[activityKey]
	return data
end

function ActivityUtil:ProcessInfoList(infoList)
	for _, info in ipairs(infoList) do
		info.IsActivity = info.ActivityKey ~= nil
		info.IsActivityInProgress = ActivityUtil:Check(info.ActivityKey)
		if info.IsActivity then
			local activityData = ActivityUtil:GetData(info.ActivityKey)
			info.ActivityName = activityData.Name
		else
			info.ActivityName = ""
		end
	end
end

function ActivityUtil:Check(activityKey)
	if not activityKey then
		return false
	end
	
	local data = Define.Activity[activityKey]
	if data then
		local startDate = data.StartDate
		local endDate = data.EndDate
		local checkDate = nil
		local result = TimeUtil:IsBetween(startDate, endDate)
		return result
	end

	return false
end


return ActivityUtil
