local UISignItem = {}
UISignItem.__index = UISignItem

function UISignItem.new()
	local self = setmetatable({}, UISignItem)
	return self
end

function UISignItem:Button_Claim(button, param)
	local uiList = param.UIListScript
	local uiRoot = param.UIRoot
	local index = param.Index
	uiList:Claim(index)
end

return UISignItem
