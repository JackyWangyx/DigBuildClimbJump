local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)

local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)
local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)

local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)
local Define = require(game.ReplicatedStorage.Define)

local Quest = {}

local QuestManager = nil

local SaveInfoTemplate = {
	["Quest"] = {
		["DailyTime"] = "20250710",
		["WeeklyTime"] = "20250710",
		["SeasonKey"] = "Season1",
		["SeasonPass"] = true,
		["SeasonPoint"] = 100,
		["CompleteSeason"] = false,
		["QuestList"] = {
			["Daily"] = {

			},
			["Weekly"] = {

			}
		}
	}
}

function Quest:Init()
	QuestManager = require(game.ServerScriptService.ScriptAlias.QuestManager)
end

function LoadInfo(player)
	local saveInfo = PlayerPrefs:GetModule(player, "Quest")
	return saveInfo
end

function Quest:GetInfo(player)
	local saveInfo = LoadInfo(player)
	if saveInfo.QuestList == nil then
		saveInfo.QuestList = {}
	end
	return saveInfo
end

function Quest:GetInfoList(player, param)
	local questType = param.Type
	local result = QuestManager:GetInfoList(player, questType)
	return result
end

--------------------------------------------------------------------------------------
-- GetReward

function Quest:GetReward(player, param)
	local questType = param.Type
	local questID = param.ID
	local result = QuestManager:GetReward(player, questType, questID)
	return result
end

--------------------------------------------------------------------------------------
-- Notify

function Quest:CheckNotify(player, param)
	local type = param.Type
	local infoList = Quest:GetInfoList(player, param)
	if type == QuestDefine.Type.Season then
		for _, questInfo in ipairs(infoList) do
			if questInfo.State == QuestDefine.State.Complete then
				return true
			end

			-- 是否处理额外奖励？
		end
	else
		for _, questInfo in ipairs(infoList) do
			if questInfo.State == QuestDefine.State.Complete then
				return true
			end
		end
	end

	return false
end

--------------------------------------------------------------------------------------
-- Season Pass

function Quest:GetPassInfo(player)
	local saveInfo = LoadInfo(player)
	local point = Quest:GetPassPoint(player)
	local passDataList = ConfigManager:GetDataList("QuestSeasonLevel")
	local count = #passDataList
	local maxPoint = passDataList[count].PassPoint
	local level = 1
	for i = 1, #passDataList do
		local data = passDataList[i]
		if data.PassPoint > point then
			level = i
			break
		end
	end

	if point > maxPoint then
		point = maxPoint
		level = count
	end

	local currentData = passDataList[level]
	local previewLevel = level - 1
	local previewPoint = 0
	if previewLevel > 0 then
		previewPoint = passDataList[previewLevel].PassPoint
	end

	local result = {
		Level = level,
		Point = point,
		MaxPoint = currentData.PassPoint,
		PassProgress = (point - previewPoint) / (currentData.PassPoint - previewPoint),
		HasSeasonPass = Quest:CheckSeasonPass(player),
		CompleteSeason = saveInfo.CompleeSeason,
	}

	return result
end

function Quest:GetExtraReward(player, param)
	local questType = param.Type
	local questID = param.ID
	local hasPass = Quest:CheckSeasonPass(player)
	local result = QuestManager:GetExtraReward(player, questType, questID, hasPass)
	return result
end

function Quest:Complete(player, param)
	local questType = param.Type
	local questID = param.ID
	local result = QuestManager:Complete(player, questType, questID)
	return result
end

function Quest:GetPassPoint(player)
	local saveInfo = LoadInfo(player)
	if not saveInfo.SeasonPoint then
		saveInfo.SeasonPoint = 0
	end

	return saveInfo.SeasonPoint
end

function Quest:AddPassPoint(player, param)
	local saveInfo = LoadInfo(player)
	if not saveInfo.SeasonPoint then
		saveInfo.SeasonPoint = 0
	end

	local value = param.Value
	saveInfo.SeasonPoint += value
	EventManager:DispatchToClient(player, EventManager.Define.RefreshPassPoint, saveInfo.PassPoint)
	PlayerRecord:AddValue(player, PlayerRecord.Define.TotalPassPoint, value)
	EventManager:Dispatch(EventManager.Define.QuestGetPassPoint, {
		Player = player,
		Value = value,
	})

	return true
end

function Quest:CheckSeasonPass(player)
	local saveInfo = LoadInfo(player)
	local hasPass = saveInfo.SeasonPass
	if hasPass == nil then
		hasPass = false
	end

	return hasPass
end

function Quest:SkipNextSeasonQuest(player)
	local infoList = Quest:GetInfoList(player, {
		Type = QuestDefine.Type.Season
	})

	local id = -1
	for index, questInfo in ipairs(infoList) do
		if questInfo.State == QuestDefine.State.Running then
			id = questInfo.ID
			break
		end
	end

	if id < 0 then
		return false
	end

	local result = Quest:Complete(player, {
		Type = QuestDefine.Type.Season, ID = id,
	})

	return result
end

function Quest:UnlockAllSeasonQuest(player)
	local dataList = ConfigManager:GetDataList("QuestSeason")
	local point = dataList[#dataList].CheckerValue
	local currentPoint = Quest:GetPassPoint(player)

	if point > currentPoint then
		local addPoint = point - currentPoint
		Quest:AddPassPoint(player, { Value = addPoint })
	end

	Quest:CompleteSeason(player)

	EventManager:DispatchToClient(player, EventManager.Define.RefreshQuest)
	return true
end

function Quest:CompleteSeason(player)
	local saveInfo = LoadInfo(player)
	saveInfo.CompleteSeason = true
	return true
end

return Quest
