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

local UITrailStore = {}

UITrailStore.UIRoot = nil
UITrailStore.InfoPart = nil

UITrailStore.ItemList = nil
UITrailStore.SelectIndex = 1

function UITrailStore:Init(root)
	UITrailStore.UIRoot = root
	UITrailStore.InfoPart = Util:GetChildByName(UITrailStore.UIRoot, "InfoLab")
end

function UITrailStore:OnShow(param)
	UITrailStore.SelectIndex = 1
	UITrailStore.ItemList = nil
end

function UITrailStore:OnHide()

end

function UITrailStore:Refresh()
	UITrailStore:RefreshItemList()
end

function UITrailStore:RefreshItemList()
	NetClient:Request("Trail", "GetPackageList", function(infoList)
		for _, info in pairs(infoList) do
			local data = ConfigManager:GetData("Trail", info.ID)
			Util:TableMerge(info, data)
		end

		-- 优先RB付费，价格升序
		infoList = Util:ListSort(infoList, {
			--function(info) return info.IsEquip and -1 or 1 end,
			function(info) return info.CostCoin end,
			function(info) return info.CostWins end,
			function(info) return info.CostRobux end,
		})
		
		UITrailStore.ItemList = UIList:LoadWithInfoData(UITrailStore.UIRoot, "UITrailItem", infoList, "Trail")
		UIList:HandleItemList(UITrailStore.ItemList, UITrailStore, "UITrailItem")
		
		UITrailStore:RefreshInfo()
	end)
end

function UITrailStore:RefreshInfo()
	UITrailStore:SelectItem(UITrailStore.SelectIndex)
end

function UITrailStore:SelectItem(index)
	if not UITrailStore.ItemList then return end
	if #UITrailStore.ItemList == 0 then
		UITrailStore.InfoPart.Visible = false
		return
	else
		UITrailStore.InfoPart.Visible = true
	end

	if index > #UITrailStore.ItemList then index = #UITrailStore.ItemList end
	UITrailStore.SelectIndex = index
	local item = UITrailStore.ItemList[index]
	local data = AttributeUtil:GetData(item)
	UIInfo:SetInfo(UITrailStore.InfoPart, data)
	local info = AttributeUtil:GetInfo(item)
	UIInfo:SetInfo(UITrailStore.InfoPart, info)
end

function UITrailStore:Button_Equip()
	if not UITrailStore.ItemList or #UITrailStore.ItemList == 0 then return end
	local selectItem = UITrailStore.ItemList[UITrailStore.SelectIndex]
	local id = AttributeUtil:GetInfoValue(selectItem, "ID")
	NetClient:Request("Trail", "Equip", {ID = id}, function()
		UITrailStore:Refresh()
	end)
end

function UITrailStore:Button_UnEquip()
	if not UITrailStore.ItemList or #UITrailStore.ItemList == 0 then return end
	local selectItem = UITrailStore.ItemList[UITrailStore.SelectIndex]
	local id = AttributeUtil:GetInfoValue(selectItem, "ID")
	NetClient:Request("Trail", "UnEquip", function()
		UITrailStore:Refresh()
	end)
end

function UITrailStore:Button_Buy()
	if not UITrailStore.ItemList or #UITrailStore.ItemList == 0 then return end
	local selectItem = UITrailStore.ItemList[UITrailStore.SelectIndex]
	local id = AttributeUtil:GetInfoValue(selectItem, "ID")
	NetClient:Request("Trail", "Buy", {ID = id}, function(result)
		if result.Success then
			task.wait()
			NetClient:Request("Trail", "Equip", {ID = id}, function()
				UITrailStore:Refresh()
			end)
		else
			UIManager:ShowMessage(result.Message)
		end
	end)
end

function UITrailStore:Button_BuyRobux()
	if not UITrailStore.ItemList or #UITrailStore.ItemList == 0 then return end
	local selectItem = UITrailStore.ItemList[UITrailStore.SelectIndex]
	local id = AttributeUtil:GetInfoValue(selectItem, "ID")
	local productKey = AttributeUtil:GetDataValue(selectItem, "ProductKey")
	IAPClient:Purchase(productKey, function(success)
		if success then
			task.wait()
			NetClient:Request("Trail", "Equip", {ID = id}, function()
				UITrailStore:Refresh()
			end)
		end
	end)
end

return UITrailStore
