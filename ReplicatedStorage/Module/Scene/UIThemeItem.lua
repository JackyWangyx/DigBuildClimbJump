local UIThemeItem = {}
UIThemeItem.__index = UIThemeItem

function UIThemeItem.new()
	local self = setmetatable({}, UIThemeItem)
	return self
end

function UIThemeItem:Button_SelectItem(button, param)
	local uiList = param.UIListScript
	local uiRoot = param.UIRoot
	local index = param.Index
	uiList:SelectItem(index)
end

return UIThemeItem
