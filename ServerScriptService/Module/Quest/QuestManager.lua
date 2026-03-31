local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local TimeUtil = require(game.ReplicatedStorage.ScriptAlias.TimeUtil)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local TimerManager = require(game.ReplicatedStorage.ScriptAlias.TimerManager)

local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)

local QuestRuntimeInfo = require(game.ServerScriptService.ScriptAlias.QuestRuntimeInfo)
local QuestRequest = require(game.ServerScriptService.ScriptAlias.Quest)

local Define = require(game.ReplicatedStorage.Define)

local QuestManager = {}

local QuestCache = {}

local InitQuestInfoTemplate = {
	ID = 0,

	State = QuestDefine.State.Running,
	Value = 0,
}

function QuestManager:Init()
	PlayerManager:HandlePlayerAddRemove(function(player)
		QuestManager:OnPlayerAdd(player)
	end, function(player)
		QuestManager:OnPlayerRemove(player)
	end, true)

	TimerManager:Interval(10, function()
		for player, cacheInfo in pairs(QuestCache) do
			QuestManager:Refresh(player)
		end
	end)
end

-- Plaeyr Add / Remove

function QuestManager:OnPlayerAdd(player)
	local cacheInfo = {
		Player = player,
		QuestList = {
			[QuestDefine.Type.Daily] = {},
			[QuestDefine.Type.Weekly] = {},
			[QuestDefine.Type.Achievement] = {},
			[QuestDefine.Type.Season] = {},
		},
	}

	QuestCache[player] = cacheInfo

	QuestManager:LoadDaily(player)
	QuestManager:LoadWeekly(player)
	QuestManager:LoadSeason(player)
	QuestManager:LoadAchievement(player)

	--local event = EventManager:GetAllEventList()
	--print(event)
end

function QuestManager:OnPlayerRemove(player)
	local cacheInfo = QuestCache[player]
	if cacheInfo and cacheInfo.QuestList then
		for questType, questList  in pairs(cacheInfo.QuestList) do
			for _, questRuntimeInfo in ipairs(questList) do
				questRuntimeInfo:Disable()
			end
		end
	end

	QuestCache[player] = nil
end

-- Init

function QuestManager:LoadQuestList(player, questType)
	local cacheInfo = QuestCache[player]
	local saveInfo = QuestRequest:GetInfo(player)
	local saveQuestList = saveInfo.QuestList[questType]
	if saveQuestList == nil then
		saveQuestList = {}
		saveInfo.QuestList[questType] = saveQuestList
	end

	local runtimeInfoList = {}
	for _, questInfo in ipairs(saveQuestList) do
		local success, message = pcall(function()
			local questRuntimeInfo = QuestRuntimeInfo.new(player, questType, questInfo)
			table.insert(runtimeInfoList, questRuntimeInfo)
			questRuntimeInfo:Enable()
		end)

		if not success then
			warn("[Quest] Load Faild : ", questType, questInfo, debug.traceback(message, 2))
		end
	end

	cacheInfo.QuestList[questType] = runtimeInfoList
end

function QuestManager:LoadDaily(player)
	local saveInfo = QuestRequest:GetInfo(player)
	local questType = QuestDefine.Type.Daily
	local c1 = saveInfo.QuestList[questType] == nil
	local c2 = saveInfo.DailyTime == nil or not TimeUtil:IsToday(saveInfo.DailyTime)
	if c1 or c2 then
		local questList = {}
		saveInfo.DailyTime = TimeUtil:GetNow()
		local questDataList = ConfigManager:GetDataList("Quest"..questType)
		--print(questType, questDataList)
		local randList = Util:ListRandomWeight(questDataList, Define.Quest.DailyQuestCount)
		for _, questData in ipairs(randList) do
			local questInfo = Util:TableCopy(InitQuestInfoTemplate)
			questInfo.ID = questData.ID
			table.insert(questList, questInfo)
		end

		saveInfo.QuestList[questType] = questList
	end

	QuestManager:LoadQuestList(player, questType)
end

function QuestManager:LoadWeekly(player)
	local saveInfo = QuestRequest:GetInfo(player)
	local questType = QuestDefine.Type.Weekly
	local c1 = saveInfo.QuestList[questType] == nil
	local c2 = saveInfo.WeeklyTime == nil or not TimeUtil:IsCurrentWeek(saveInfo.WeeklyTime)
	if c1 or c2 then
		local questList = {}
		saveInfo.WeeklyTime = TimeUtil:GetNow()
		local questDataList = ConfigManager:GetDataList("Quest"..questType)
		local randList = Util:ListRandomWeight(questDataList, Define.Quest.WeeklyQuestCount)
		for _, questData in ipairs(randList) do
			local questInfo = Util:TableCopy(InitQuestInfoTemplate)
			questInfo.ID = questData.ID
			table.insert(questList, questInfo)
		end

		saveInfo.QuestList[questType] = questList
	end

	QuestManager:LoadQuestList(player, questType)
end

function QuestManager:LoadSeason(player)
	local saveInfo = QuestRequest:GetInfo(player)
	local questType = QuestDefine.Type.Season
	local c1 = saveInfo.QuestList[questType] == nil
	local c2 = saveInfo.SeasonKey == nil or saveInfo.SeasonKey ~= Define.Quest.SeasonKey
	if c1 or c2 then
		local questList = {}
		saveInfo.SeasonKey = Define.Quest.SeasonKey
		saveInfo.SeasonPass = false
		saveInfo.SeasonPoint = 0
		saveInfo.CompleteSeason = false
		local questDataList = ConfigManager:GetDataList("Quest"..questType)
		local count = #questDataList
		for index, questData in ipairs(questDataList) do
			local questInfo = Util:TableCopy(InitQuestInfoTemplate)
			questInfo.ID = questData.ID
			questInfo.GetExtraReward = false
			if index == count then
				questInfo.IsLast = true
				--print("Last", count)
			end

			table.insert(questList, questInfo)
		end

		saveInfo.QuestList[questType] = questList
	end

	QuestManager:LoadQuestList(player, questType)
end

function QuestManager:LoadAchievement(player)
	local saveInfo = QuestRequest:GetInfo(player)
	local questType = QuestDefine.Type.Achievement
	local questList = saveInfo.QuestList[questType]
	if questList == nil then
		questList = {}
		saveInfo.QuestList[questType] = questList
	end

	local questDataList = ConfigManager:GetDataList("Quest"..questType)
	for _, questData in ipairs(questDataList) do
		local questInfo = Util:ListFind(questList, function(info)
			return info.ID == questData.ID
		end)

		if not questInfo then
			questInfo = Util:TableCopy(InitQuestInfoTemplate)
			questInfo.ID = questData.ID
			table.insert(questList, questInfo)
		end
	end

	QuestManager:LoadQuestList(player, questType)
end

-- Get

function QuestManager:GetInfoList(player, questType)
	local cacheInfo = QuestCache[player]
	local runtimeInfoList = cacheInfo.QuestList[questType]
	local result = {}
	for _, questRuntimeInfo in ipairs(runtimeInfoList) do
		local nextQuest = Util:ListFind(runtimeInfoList, function(item)
			return item.Data.PreviewQuestID == questRuntimeInfo.ID
		end)

		local previewQuest = Util:ListFind(runtimeInfoList, function(item)
			return item.ID == questRuntimeInfo.Data.PreviewQuestID
		end)

		local isNormalQuest = previewQuest == nil and nextQuest == nil
		local isQuestChainStart = previewQuest == nil and nextQuest ~= nil
		local isQuestChainEnd = previewQuest ~= nil and nextQuest == nil

		-- 非任务链
		if isNormalQuest then
			local info = questRuntimeInfo:GetClientInfo()
			table.insert(result, info)
		else
			local c1 = questRuntimeInfo.Info.State == QuestDefine.State.Running
			local c2 = questRuntimeInfo.Info.State == QuestDefine.State.Complete
			--print(questRuntimeInfo.Data.Name, isNormalQuest, isQuestChainStart, isQuestChainEnd)
			if isQuestChainStart then
				-- 任务链起点
				if c1 or c2 then
					local info = questRuntimeInfo:GetClientInfo()
					table.insert(result, info)
				end
			elseif isQuestChainEnd then
				-- 任务链终点
				if previewQuest.Info.State == QuestDefine.State.GetReward then
					local info = questRuntimeInfo:GetClientInfo()
					table.insert(result, info)
				end	
			else		
				-- 任务链过程中
				if c1 or c2 then
					if previewQuest.Info.State == QuestDefine.State.GetReward then
						local info = questRuntimeInfo:GetClientInfo()
						table.insert(result, info)
					end 
				end
			end
		end
	end

	return result
end

function QuestManager:GetRuntimeInfo(player, questType, questID)
	local cacheInfo = QuestCache[player]
	local runtimeInfoList = cacheInfo.QuestList[questType]
	for _, questRuntimeInfo in ipairs(runtimeInfoList) do
		if questRuntimeInfo.Info.ID == questID then
			return questRuntimeInfo
		end	
	end

	return nil
end

function QuestManager:GetReward(player, questType, questID)
	local questRuntimeInfo = QuestManager:GetRuntimeInfo(player, questType, questID)
	if not questRuntimeInfo then
		return false
	end

	local result = questRuntimeInfo:GetReward()
	return result
end

function QuestManager:GetExtraReward(player, questType, questID, hasPass)
	if not hasPass then return false end
	local questRuntimeInfo = QuestManager:GetRuntimeInfo(player, questType, questID)
	if not questRuntimeInfo then
		return false
	end

	local result = questRuntimeInfo:GetExtraReward()
	return result
end

function QuestManager:Complete(player, questType, questID)
	local questRuntimeInfo = QuestManager:GetRuntimeInfo(player, questType, questID)
	if not questRuntimeInfo then
		return false
	end

	local result = questRuntimeInfo:Complete()
	return result
end

-- Refresh

function QuestManager:Refresh(player)
	local cacheInfo = QuestCache[player]
	for questType, questList  in pairs(cacheInfo.QuestList) do
		for _, questRuntimeInfo in ipairs(questList) do
			questRuntimeInfo:Refresh()
		end
	end
end

return QuestManager
