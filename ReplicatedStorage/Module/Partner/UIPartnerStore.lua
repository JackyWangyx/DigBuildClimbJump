local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local AttributeUtil = require(game.ReplicatedStorage.ScriptAlias.AttributeUtil)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local UIListSelect = require(game.ReplicatedStorage.ScriptAlias.UIListSelect)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local UIConfirm = require(game.ReplicatedStorage.ScriptAlias.UIConfirm)
local PetUtil = require(game.ReplicatedStorage.ScriptAlias.PetUtil)
local TweenUtil = require(game.ReplicatedStorage.ScriptAlias.TweenUtil)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local ActivityUtil = require(game.ReplicatedStorage.ScriptAlias.ActivityUtil)

local Define = require(game.ReplicatedStorage.Define)

local UIPartnerStore = {}

UIPartnerStore.UIRoot = nil
UIPartnerStore.InfoPart = nil

UIPartnerStore.ItemList = nil
UIPartnerStore.SelectIndex = 1

function UIPartnerStore:Init(root)
	UIPartnerStore.UIRoot = root
	UIPartnerStore.InfoPart = Util:GetChildByName(UIPartnerStore.UIRoot, "InfoLab")
end

function UIPartnerStore:OnShow(param)
	UIPartnerStore.SelectIndex = 1
	UIPartnerStore.ItemList = nil
end

function UIPartnerStore:OnHide()

end

function UIPartnerStore:Refresh()
	UIPartnerStore:RefreshItemList()
end

function UIPartnerStore:RefreshItemList()
	NetClient:Request("Partner", "GetPackageList", function(infoList)
		for _, info in pairs(infoList) do
			local data = ConfigManager:GetData("Partner", info.ID)
			Util:TableMerge(info, data)
		end
		
		ActivityUtil:ProcessInfoList(infoList)

		infoList = Util:ListSort(infoList, {
			function(info) return info.CostCoin end,
			function(info) return info.CostWins end,
			function(info) return info.CostRobux end,
		})

		UIPartnerStore:MoveAfterCondition(infoList, function(info)
			return info.ID == 1
		end, function(info)
			return info.CostRobux > 0
		end)
		UIPartnerStore.ItemList = UIList:LoadWithInfoData(UIPartnerStore.UIRoot, "UIPartnerItem", infoList, "Partner")
		UIList:HandleItemList(UIPartnerStore.ItemList, UIPartnerStore, "UIPartnerItem")
		
		UIPartnerStore:RefreshInfo()
	end)
end

function UIPartnerStore:MoveAfterCondition(data, conditionA, conditionB)
	local indexA, lastIndexB, elementA
	for i, v in ipairs(data) do
		if not indexA and conditionA(v) then
			indexA = i
			elementA = v
		end
		if conditionB(v) then
			lastIndexB = i
		end
	end

	if not indexA or not lastIndexB then
		return
	end

	table.remove(data, indexA)
	if indexA < lastIndexB then
		lastIndexB = lastIndexB - 1
	end

	table.insert(data, lastIndexB + 1, elementA)
end

function UIPartnerStore:RefreshInfo()
	UIPartnerStore:SelectItem(UIPartnerStore.SelectIndex)
end

function UIPartnerStore:SelectItem(index)
	if not UIPartnerStore.ItemList then return end
	if #UIPartnerStore.ItemList == 0 then
		UIPartnerStore.InfoPart.Visible = false
		return
	else
		UIPartnerStore.InfoPart.Visible = true
	end

	if index > #UIPartnerStore.ItemList then index = #UIPartnerStore.ItemList end
	UIPartnerStore.SelectIndex = index
	local item = UIPartnerStore.ItemList[index]
	local data = AttributeUtil:GetData(item)
	UIInfo:SetInfo(UIPartnerStore.InfoPart, data)
	local info = AttributeUtil:GetInfo(item)
	UIInfo:SetInfo(UIPartnerStore.InfoPart, info)
end

function UIPartnerStore:Button_Equip()
	if not UIPartnerStore.ItemList or #UIPartnerStore.ItemList == 0 then return end
	local selectItem = UIPartnerStore.ItemList[UIPartnerStore.SelectIndex]
	local id = AttributeUtil:GetInfoValue(selectItem, "ID")
	NetClient:Request("Partner", "Equip", {ID = id}, function()
		UIPartnerStore:Refresh()
	end)
end

function UIPartnerStore:Button_UnEquip()
	if not UIPartnerStore.ItemList or #UIPartnerStore.ItemList == 0 then return end
	local selectItem = UIPartnerStore.ItemList[UIPartnerStore.SelectIndex]
	local id = AttributeUtil:GetInfoValue(selectItem, "ID")
	NetClient:Request("Partner", "UnEquip", function()
		UIPartnerStore:Refresh()
	end)
end

function UIPartnerStore:Button_Buy()
	if not UIPartnerStore.ItemList or #UIPartnerStore.ItemList == 0 then return end
	local selectItem = UIPartnerStore.ItemList[UIPartnerStore.SelectIndex]
	local id = AttributeUtil:GetInfoValue(selectItem, "ID")
	NetClient:Request("Partner", "Buy", {ID = id}, function(result)
		if result.Success then
			task.wait()
			NetClient:Request("Partner", "Equip", {ID = id}, function()
				task.wait()
				UIPartnerStore:Refresh()
			end)
		else
			UIManager:ShowMessage(result.Message)
		end
	end)
end

function UIPartnerStore:Button_BuyRobux()
	if not UIPartnerStore.ItemList or #UIPartnerStore.ItemList == 0 then return end
	local selectItem = UIPartnerStore.ItemList[UIPartnerStore.SelectIndex]
	local id = AttributeUtil:GetInfoValue(selectItem, "ID")
	local productKey = AttributeUtil:GetInfoValue(selectItem, "ProductKey")
	IAPClient:Purchase(productKey, function(success)
		if success then
			task.wait()
			NetClient:Request("Partner", "Equip", {ID = id}, function()
				UIPartnerStore:Refresh()
			end)
		end
	end)
end

function UIPartnerStore:Button_Activity()
	if not UIPartnerStore.ItemList or #UIPartnerStore.ItemList == 0 then return end
	local selectItem = UIPartnerStore.ItemList[UIPartnerStore.SelectIndex]
	local info = AttributeUtil:GetInfo(selectItem)
	local activityKey = info.ActivityKey
	if activityKey then
		UIManager:ShowAndHideOther("UISignActivity", {
			ActivityKey = activityKey
		})
	end
end

return UIPartnerStore
