local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)

local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)

local RewardHandler = require(game.ServerScriptService.ScriptAlias.RewardHandler)

local Define = require(game.ReplicatedStorage.Define)

local QuestRuntimeInfo = {}
QuestRuntimeInfo.__index = QuestRuntimeInfo

function QuestRuntimeInfo.new(player, questType, questInfo)
	local self = setmetatable({}, QuestRuntimeInfo)
	self.Player = player
	self.Type = questType
	self.Info = questInfo
	self.ID = questInfo.ID
	self.Data = ConfigManager:GetData("Quest"..questType, questInfo.ID)
	local checkerFolder = script.Parent.Checker
	local checkerName = self.Data.CheckerType.."Checker"
	local checkerScript = require(checkerFolder:FindFirstChild(checkerName))
	local checker = checkerScript.new(player, questType, self)
	self.Checker = checker
	return self
end

function QuestRuntimeInfo:Enable()
	self.Checker:Enable()
	self.Checker:Refresh()
end

function QuestRuntimeInfo:Disable()
	self.Checker:Disable()
end

function QuestRuntimeInfo:Refresh()
	self.Checker:Refresh()
end

function QuestRuntimeInfo:GetClientInfo()
	local result = {}
	self.Checker:OnEvent({Player = self.Player, Value = 0})
	self.Checker:Refresh()
	Util:TableMerge(result, self.Data)
	Util:TableMerge(result, self.Info)
	result.Progress = result.Value / result.CheckerValue
	if result.Progress > 1 then
		result.Progress = 1
	end
	
	return result
end

function QuestRuntimeInfo:GetReward()
	local state = self.Info.State
	if state == QuestDefine.State.Complete then
		local player = self.Player
		local rewardType = self.Data.RewardType
		local rewardID = self.Data.RewardID
		local rewardCount = self.Data.RewardCount
		RewardHandler:GetReward(player, rewardType, rewardID, rewardCount)	
		self.Info.State = QuestDefine.State.GetReward
		return true
	else
		return false
	end
end

function QuestRuntimeInfo:GetExtraReward()
	local state = self.Info.State
	local c1 = state == QuestDefine.State.Complete or state == QuestDefine.State.GetReward
	local c2 = self.Info.GetExtraReward == false
	if c1 and c2 then
		local player = self.Player
		local data = ConfigManager:GetData("QuestSeasonPremium", self.Info.ID)
		local rewardType = data.PremiumRewardType
		local rewardID = data.PremiumRewardID
		local rewardCount =data.PremiumRewardCount
		RewardHandler:GetReward(player, rewardType, rewardID, rewardCount)	
		self.Info.GetExtraReward = true
		return true
	else
		return false
	end
end

function QuestRuntimeInfo:Complete()
	local state = self.Info.State
	if state == QuestDefine.State.Running then
		self.Info.Value = self.Data.CheckerValue
		self.Info.State = QuestDefine.State.Complete
		
		if self.Type == QuestDefine.Type.Season then
			local levelData = ConfigManager:GetData("QuestSeasonLevel", self.Info.ID)
			local point = levelData.PassPoint
			local questRequest = require(game.ServerScriptService.ScriptAlias.Quest)
			local currentPoint = questRequest:GetPassPoint(self.Player)
			if point > currentPoint then
				local addPoint = point - currentPoint
				questRequest:AddPassPoint(self.Player, { Value = addPoint })
			end
			
			local isLast = self.Info.IsLast
			if isLast then
				questRequest:CompleteSeason(self.Player)
			end
			
			AnalyticsManager:Event(self.Player, AnalyticsManager.Define.CompleteQuest..Define.Quest.SeasonKey)
		elseif self.Type == QuestDefine.Type.Weekly then
			AnalyticsManager:Event(self.Player, AnalyticsManager.Define.CompleteQuestWeekly)
		elseif self.Type == QuestDefine.Type.Daily then
			AnalyticsManager:Event(self.Player, AnalyticsManager.Define.CompleteQuestDaily)
		elseif self.Type == QuestDefine.Type.Achievement then
			AnalyticsManager:Event(self.Player, AnalyticsManager.Define.CompleteQuestAchievement)
		end
		
		EventManager:DispatchToClient(self.Player, EventManager.Define.RefreshQuest)
		
		return true
	else
		return false
	end
end

return QuestRuntimeInfo


