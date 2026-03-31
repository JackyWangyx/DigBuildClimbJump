local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local AttributeUtil = require(game.ReplicatedStorage.ScriptAlias.AttributeUtil)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local UIListSelect = require(game.ReplicatedStorage.ScriptAlias.UIListSelect)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local UIConfirm = require(game.ReplicatedStorage.ScriptAlias.UIConfirm)
local AnimalUtil = require(game.ReplicatedStorage.ScriptAlias.AnimalUtil)
local TweenUtil = require(game.ReplicatedStorage.ScriptAlias.TweenUtil)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local ActivityUtil = require(game.ReplicatedStorage.ScriptAlias.ActivityUtil)

local UIAnimalStore = {}

UIAnimalStore.UIRoot = nil
UIAnimalStore.InfoPart = nil

UIAnimalStore.ItemList = nil
UIAnimalStore.SelectIndex = 1

function UIAnimalStore:Init(root)
	UIAnimalStore.UIRoot = root
	UIAnimalStore.InfoPart = Util:GetChildByName(UIAnimalStore.UIRoot, "InfoLab")
end

function UIAnimalStore:OnShow(param)
	UIAnimalStore.InfoPart.Visible = false
	UIAnimalStore.SelectIndex = 1
	UIAnimalStore.ItemList = nil
end

function UIAnimalStore:OnHide()

end

function UIAnimalStore:Refresh()
	UIAnimalStore:RefreshItemList()
end

function UIAnimalStore:RefreshItemList()
	local dataList = AnimalUtil:GetStoreList()
	ActivityUtil:ProcessInfoList(dataList)
	
	UIAnimalStore.ItemList = UIList:LoadWithInfo(UIAnimalStore.UIRoot, "UIAnimalStoreItem", dataList)
	UIList:HandleItemList(UIAnimalStore.ItemList, UIAnimalStore, "UIAnimalStoreItem")
	
	if #dataList > 0 then
		UIAnimalStore.InfoPart.Visible = true
	end
	
	UIAnimalStore:RefreshInfo()
end

function UIAnimalStore:RefreshInfo()
	UIAnimalStore:SelectItem(UIAnimalStore.SelectIndex)
end

function UIAnimalStore:SelectItem(index)
	if not UIAnimalStore.ItemList then return end
	if #UIAnimalStore.ItemList == 0 then
		UIAnimalStore.InfoPart.Visible = false
		return
	else
		UIAnimalStore.InfoPart.Visible = true
	end

	if index > #UIAnimalStore.ItemList then index = #UIAnimalStore.ItemList end
	UIAnimalStore.SelectIndex = index
	local item = UIAnimalStore.ItemList[index]
	local data = AttributeUtil:GetData(item)
	UIInfo:SetInfo(UIAnimalStore.InfoPart, data)
	local info = AttributeUtil:GetInfo(item)
	UIInfo:SetInfo(UIAnimalStore.InfoPart, info)
end

function UIAnimalStore:Button_Equip()
	if not UIAnimalStore.ItemList or #UIAnimalStore.ItemList == 0 then return end
	local selectItem = UIAnimalStore.ItemList[UIAnimalStore.SelectIndex]
	local id = AttributeUtil:GetInfoValue(selectItem, "ID")
	NetClient:Request("Animal", "Equip", {ID = id}, function()
		UIAnimalStore:Refresh()
	end)
end

function UIAnimalStore:Button_UnEquip()
	if not UIAnimalStore.ItemList or #UIAnimalStore.ItemList == 0 then return end
	local selectItem = UIAnimalStore.ItemList[UIAnimalStore.SelectIndex]
	local id = AttributeUtil:GetInfoValue(selectItem, "ID")
	NetClient:Request("Animal", "UnEquip", function()
		UIAnimalStore:Refresh()
	end)
end

function UIAnimalStore:Button_Buy()
	if not UIAnimalStore.ItemList or #UIAnimalStore.ItemList == 0 then return end
	local selectItem = UIAnimalStore.ItemList[UIAnimalStore.SelectIndex]
	local data = AttributeUtil:GetInfo(selectItem)
	local id = AttributeUtil:GetInfoValue(selectItem, "ID")
	NetClient:Request("Animal", "Buy", {ID = id}, function(result)
		if result.Success then
			UIManager:ShowMessageWithIcon(data.Icon, "Got "..data.Name.." X1")
		else
			UIManager:ShowMessage(result.Message)
		end
	end)
end

function UIAnimalStore:Button_BuyRobux()
	if not UIAnimalStore.ItemList or #UIAnimalStore.ItemList == 0 then return end
	local selectItem = UIAnimalStore.ItemList[UIAnimalStore.SelectIndex]
	local data = AttributeUtil:GetInfo(selectItem)
	local id = AttributeUtil:GetInfoValue(selectItem, "ID")
	local productKey = AttributeUtil:GetInfoValue(selectItem, "ProductKey")
	IAPClient:Purchase(productKey, function(success)
		if success then
			UIManager:ShowMessageWithIcon(data.Icon, "Got "..data.Name.." X1")
		end
	end)
end

function UIAnimalStore:Button_Activity()
	if not UIAnimalStore.ItemList or #UIAnimalStore.ItemList == 0 then return end
	local selectItem = UIAnimalStore.ItemList[UIAnimalStore.SelectIndex]
	local info = AttributeUtil:GetInfo(selectItem)
	local activityKey = info.ActivityKey
	if activityKey then
		UIManager:ShowAndHideOther("UISignActivity", {
			Key = activityKey
		})
	end
end

return UIAnimalStore
