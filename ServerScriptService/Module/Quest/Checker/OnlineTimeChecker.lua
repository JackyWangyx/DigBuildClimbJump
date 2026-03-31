local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)

local PlayerCache = require(game.ServerScriptService.ScriptAlias.PlayerCache)
local QuestChecker = require(game.ServerScriptService.ScriptAlias.QuestChecker)

local OnlineTimeChecker = setmetatable({}, {__index = QuestChecker})
OnlineTimeChecker.__index = OnlineTimeChecker

function OnlineTimeChecker.new(player, questType, questInfo)
	local self = setmetatable(QuestChecker.new(player, questType, questInfo), OnlineTimeChecker) 
	self.StartTime = self.Info.Value
	return self
end

function OnlineTimeChecker:Refresh()
	local state = self.Info.State
	if state ==  QuestDefine.State.Running then
		if self.Mode == QuestDefine.CheckerMode.Normal then
			self.Info.Value = self.StartTime + PlayerCache:GetOnlineTime(self.Player)
		end

		if self.Info.Value >= self.Data.CheckerValue then
			self.Info.Value = self.Data.CheckerValue
		end
	else
		self.Info.Value = self.Data.CheckerValue
	end

	local check = self.Info.Value >= self.Data.CheckerValue
	if state ==  QuestDefine.State.Running and check then 
		self.Info.State = QuestDefine.State.Complete	
		if self.Data.AutoGetReward then
			self.RuntimeInfo:GetReward()
		end
	end
end

return OnlineTimeChecker