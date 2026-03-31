local QuestDefine = {}

QuestDefine.Type = {
	Achievement = "Achievement",
	Daily = "Daily",
	Weekly = "Weekly",
	Season = "Season",
}

QuestDefine.CheckerMode = {
	Normal = 1,					-- 监听事件传递累计值
	RecordValue = 2,			-- 监听事件触发更新直接获取指定值
}

QuestDefine.State = {
	Prepare = 1,
	Running = 2,
	Complete = 3,
	GetReward = 4,
}

local DataTemplate = {
	ID = 0,
	
	Name = "",
	Description = "",
	Icon = "",
	
	PreviewQuestID = nil,
	
	CheckerType = 0,
	CheckerParam = 0,
	CheckerValue = 0,
	
	RewardIcon = "",
	RewardType = 0,
	RewardID = 0,
	RewardCount = 0,
	
	PremiumRRewardIcon = "",
	PremiumRewardType = 0,
	PremiumRewardID = 0,
	PremiumRewardCount = 0,
		
	Weight = 10,
	
	AutoGetReward = true,
}

local InfoTemplate = {
	ID = 0,
	
	State = 0,
	Value = 0,
}

return QuestDefine