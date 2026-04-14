local UIThemeItem = {}
UIThemeItem.__index = UIThemeItem

function UIThemeItem.new()
	local self = setmetatable({}, UIThemeItem)
	return self
end

function UIThemeItem:Button_Select(button, param)
	local uiList = param.UIListScript
	local uiRoot = param.UIRoot
	local index = param.Index
	uiList:Select(index)
end

function UIThemeItem:Button_Buy(button, param)
	local uiList = param.UIListScript
	local uiRoot = param.UIRoot
	local index = param.Index
	uiList:Buy(index)
end

return UIThemeItem
