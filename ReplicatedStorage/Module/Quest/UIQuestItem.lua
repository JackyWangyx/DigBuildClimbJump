local UIQuestItem = {}

UIQuestItem.__index = UIQuestItem

function UIQuestItem.new()
	local self = setmetatable({}, UIQuestItem)
	return self
end

function UIQuestItem:Button_SelectItem(button, param)
	local uiList = param.UIListScript
	local uiRoot = param.UIRoot
	local index = param.Index
	uiList:SelectItem(index)
end

function UIQuestItem:Button_Skip(button, param)
	local uiList = param.UIListScript
	local uiRoot = param.UIRoot
	local index = param.Index
	uiList:Skip(index)
end

function UIQuestItem:Button_GetReward(button, param)
	local uiList = param.UIListScript
	local uiRoot = param.UIRoot
	local index = param.Index
	uiList:GetReward(index)
end

function UIQuestItem:Button_GetExtraReward(button, param)
	local uiList = param.UIListScript
	local uiRoot = param.UIRoot
	local index = param.Index
	uiList:GetExtraReward(index)
end

return UIQuestItem