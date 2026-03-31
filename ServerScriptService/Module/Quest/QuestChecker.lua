local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)

local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)

local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)

local QuestChecker = {}
QuestChecker.__index = QuestChecker

function QuestChecker.new(player, questType, questRuntimeInfo)
	local self = setmetatable({}, QuestChecker)
	self.Player = player
	self.Type = questType
	if questType == QuestDefine.Type.Achievement then
		self.Mode = QuestDefine.CheckerMode.RecordValue
	else
		self.Mode = QuestDefine.CheckerMode.Normal
	end

	self.RuntimeInfo = questRuntimeInfo
	self.Info = questRuntimeInfo.Info
	self.Data = ConfigManager:GetData("Quest"..questType, self.Info.ID)
	return self
end

function QuestChecker:GetEventType()
	return "Quest"..self.Data.CheckerType
end

function QuestChecker:GetRecordType()
	return "Total"..self.Data.CheckerType
end

function QuestChecker:Enable()
	self.CheckFunction = function(param)
		self:OnEvent(param)
	end

	local eventType = self:GetEventType()
	EventManager:Listen(eventType, self.CheckFunction)
end

function QuestChecker:Disable()
	local eventType = self:GetEventType()
	EventManager:Remove(eventType, self.CheckFunction)
end

function QuestChecker:OnEvent(param)
	local state = self.Info.State
	if state ~= QuestDefine.State.Running then return end
	if self.Mode == QuestDefine.CheckerMode.Normal then
		-- 监听事件传递的值，累计
		local player = param.Player
		if player ~= self.Player then return end
		if param.Param ~= nil and param.Param ~= self.Data.CheckerParam then return end
		local value = param.Value
		self.Info.Value += value
	elseif self.Mode == QuestDefine.CheckerMode.RecordValue then
		-- 刷新获取指定的值，缓存，最高记录等
		local player = param.Player
		if player ~= self.Player then return end
		local value = self:GetRecordValue()
		self.Info.Value = value
	end

	self:Refresh()
end

function QuestChecker:Refresh()
	local state = self.Info.State
	if self.Info.Value > self.Data.CheckerValue then
		self.Info.Value = self.Data.CheckerValue
	end

	local check = self.Info.Value >= self.Data.CheckerValue
	if state ==  QuestDefine.State.Running and check then 
		self.Info.State = QuestDefine.State.Complete	
		if self.Data.AutoGetReward then
			self.RuntimeInfo:GetReward()
		end

		EventManager:DispatchToClient(self.Player, EventManager.Define.RefreshQuest)
	end
end

function QuestChecker:GetRecordValue()
	local recordKey = self:GetRecordType()
	local value =  PlayerRecord:GetValue(self.Player, recordKey)
	return value
end

return QuestChecker


