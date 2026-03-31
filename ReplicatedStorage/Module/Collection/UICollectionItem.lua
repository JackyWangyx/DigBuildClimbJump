local UICollectionItem = {}

UICollectionItem.__index = UICollectionItem

function UICollectionItem.new()
	local self = setmetatable({}, UICollectionItem)
	return self
end

function UICollectionItem:Button_SelectItem(button, param)
	local uiList = param.UIListScript
	local uiRoot = param.UIRoot
	local index = param.Index
	uiList:SelectItem(index)
end

return UICollectionItem