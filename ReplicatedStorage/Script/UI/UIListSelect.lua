local AttributeUtil = require(game.ReplicatedStorage.ScriptAlias.AttributeUtil)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local UIListSelect = {}

local ConnectionCahce = {}

-- 通用选择列表实现，在列表按钮本身事件都已经绑定完成后再调用
function UIListSelect:HandleSelectMany(itemList, selectFunc)
	if not itemList then return end
	UIListSelect:DeSelectAll(itemList)
	for _, item in pairs(itemList) do
		local button = Util:GetChildByName(item, "Button_SelectItem")
		local connection = ConnectionCahce[button]
		if connection then
			connection:Disconnect()
		end
		connection = button.MouseButton1Click:Connect(function()
			UIListSelect:ClickSelect(item)
			local isSelect = AttributeUtil:GetInfoValue(item, "IsSelect")
			if isSelect and selectFunc then
				selectFunc(item)
			end
		end)
		
		ConnectionCahce[button] = connection
    end
end

function UIListSelect:HandleSelectOne(itemList, selectFunc)
	if not itemList then return end
	UIListSelect:DeSelectAll(itemList)
	for _, item in pairs(itemList) do
		local button = Util:GetChildByName(item, "Button_SelectItem")
		local connection = ConnectionCahce[button]
		if connection then
			connection:Disconnect()
		end
		connection = button.MouseButton1Click:Connect(function()
			UIListSelect:DeSelectAll(itemList)
			UIListSelect:ClickSelect(item)
			local isSelect = AttributeUtil:GetInfoValue(item, "IsSelect")
			if isSelect and selectFunc then
				selectFunc(item)
			end
		end)
		
		ConnectionCahce[button] = connection
	end
end

function UIListSelect:SetSelect(item, isSelect)
	if not item then return end
    AttributeUtil:SetInfoValue(item, "IsSelect", isSelect)
    UIInfo:SetValue(item, "IsSelect", isSelect)
end

function UIListSelect:Select(item)
	if not item then return end
    UIListSelect:SetSelect(item, true)
end

function UIListSelect:DeSelect(item)
	if not item then return end
    UIListSelect:SetSelect(item, false)
end

function UIListSelect:ClickSelect(item)
	if not item then return end
    local isSelect = AttributeUtil:GetInfoValue(item, "IsSelect")
    UIListSelect:SetSelect(item, not isSelect)
end

function UIListSelect:SelectAll(itemList)
	if not itemList then return end
	for _, item in ipairs(itemList) do
        UIListSelect:SetSelect(item, true)
    end
end

function UIListSelect:DeSelectAll(itemList)
	if not itemList then return end
	for _, item in ipairs(itemList) do
        UIListSelect:SetSelect(item, false)
    end
end

function UIListSelect:GetSelectList(itemList)
	if not itemList then return {} end
    local selectItemList = {}
	for _, item in ipairs(itemList) do
        local isSelect = AttributeUtil:GetInfoValue(item, "IsSelect")
        if isSelect then
            table.insert(selectItemList, item)
        end
    end
    return selectItemList
end

return UIListSelect

