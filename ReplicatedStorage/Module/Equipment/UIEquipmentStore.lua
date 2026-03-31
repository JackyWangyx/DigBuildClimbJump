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
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local ActivityUtil = require(game.ReplicatedStorage.ScriptAlias.ActivityUtil)

local Define = require(game.ReplicatedStorage.Define)

local UIEquipmentStore = {}

UIEquipmentStore.UIRoot = nil
UIEquipmentStore.InfoPart = nil

UIEquipmentStore.ItemList = nil
UIEquipmentStore.SelectIndex = 1

function UIEquipmentStore:Init(root)
	UIEquipmentStore.UIRoot = root
	UIEquipmentStore.InfoPart = Util:GetChildByName(UIEquipmentStore.UIRoot, "InfoLab")
end

function UIEquipmentStore:OnShow(param)
	UIEquipmentStore.InfoPart.Visible = false
	UIEquipmentStore.SelectIndex = 1
	UIEquipmentStore.ItemList = nil
end

function UIEquipmentStore:OnHide()

end

function UIEquipmentStore:Refresh()
	UIEquipmentStore:RefreshItemList()
end

function UIEquipmentStore:RefreshItemList()
	NetClient:Request("Equipment", "GetPackageList", function(infoList)
		local showInfoList = {}
		for _, info in ipairs(infoList) do
			local data = ConfigManager:GetData("Equipment", info.ID)
			local isRobuxEquipment = not Util:IsStrEmpty(data.ProductKey)
			--print(isRobuxEquipment, data)
			if not info.IsBuy and isRobuxEquipment then
				continue
			end
			
			Util:TableMerge(info, data)
			table.insert(showInfoList, info)
		end

		ConfigManager:FliterDataSource("Equipment", showInfoList)
		ActivityUtil:ProcessInfoList(showInfoList)
		
		-- 优先RB付费，价格升序
		--infoList = Util:ListSort(infoList, {
		--	--function(info) return info.IsEquip and -1 or 1 end,
		--	function(info) return info.CostCoin end,
		--	function(info) return info.CostWins end,
		--	function(info) return info.CostRobux end,
		--})
		
		-- 按可购买顺序
		showInfoList = Util:ListSort(showInfoList, {
			function(info) return info.BuyOrder end,
			function(info) return info.CostRobux end,
		})

		UIEquipmentStore:MoveAfterCondition(showInfoList, function(info)
			return info.ID == 1
		end, function(info)
			return info.CostRobux > 0
		end)
		
		UIEquipmentStore.ItemList = UIList:LoadWithInfoData(UIEquipmentStore.UIRoot, "UIEquipmentItem", showInfoList, "Equipment")
		UIList:HandleItemList(UIEquipmentStore.ItemList, UIEquipmentStore, "UIEquipmentItem")
		
		UIEquipmentStore:RefreshInfo()
		
		if #showInfoList > 0 then
			UIEquipmentStore.InfoPart.Visible = true
		end		
	end)
end

function UIEquipmentStore:MoveAfterCondition(data, conditionA, conditionB)
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

function UIEquipmentStore:RefreshInfo()
	UIEquipmentStore:SelectItem(UIEquipmentStore.SelectIndex)
end

function UIEquipmentStore:SelectItem(index)
	if not UIEquipmentStore.ItemList then return end
	if #UIEquipmentStore.ItemList == 0 then
		UIEquipmentStore.InfoPart.Visible = false
		return
	else
		UIEquipmentStore.InfoPart.Visible = true
	end

	if index > #UIEquipmentStore.ItemList then index = #UIEquipmentStore.ItemList end
	UIEquipmentStore.SelectIndex = index
	local item = UIEquipmentStore.ItemList[index]
	local data = AttributeUtil:GetData(item)
	UIInfo:SetInfo(UIEquipmentStore.InfoPart, data)
	local info = AttributeUtil:GetInfo(item)
	UIInfo:SetInfo(UIEquipmentStore.InfoPart, info)
	
	--local infoNewbiePart = Util:GetChildByName(UIEquipmentStore.InfoPart, "Info_CostNewbie")
	--if infoNewbiePart then
	--	infoNewbiePart.Visible = data.ID == 20
	--end	
end

function UIEquipmentStore:Button_Equip()
	if not UIEquipmentStore.ItemList or #UIEquipmentStore.ItemList == 0 then return end
	UIEquipmentStore:CheckBeforeChangeEquipment()
	local selectItem = UIEquipmentStore.ItemList[UIEquipmentStore.SelectIndex]
	local id = AttributeUtil:GetInfoValue(selectItem, "ID")
	NetClient:Request("Equipment", "Equip", {ID = id}, function()
		UIEquipmentStore:Refresh()
		EventManager:Dispatch(EventManager.Define.RefreshEquipment)
	end)
end

function UIEquipmentStore:Button_UnEquip()
	if not UIEquipmentStore.ItemList or #UIEquipmentStore.ItemList == 0 then return end
	UIEquipmentStore:CheckBeforeChangeEquipment()
	local selectItem = UIEquipmentStore.ItemList[UIEquipmentStore.SelectIndex]
	local id = AttributeUtil:GetInfoValue(selectItem, "ID")
	NetClient:Request("Equipment", "UnEquip", function()
		UIEquipmentStore:Refresh()
		EventManager:Dispatch(EventManager.Define.RefreshEquipment)
	end)
end

function UIEquipmentStore:CheckBeforeChangeEquipment()
	if not UIEquipmentStore.ItemList or #UIEquipmentStore.ItemList == 0 then return end
	local status = NetClient:RequestWait("Player", "GetStatus")
	if status == Define.PlayerStatus.Training then
		local trainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)
		trainingMachine:End()
	end
end

function UIEquipmentStore:Button_Buy()
	if not UIEquipmentStore.ItemList or #UIEquipmentStore.ItemList == 0 then return end
	local selectItem = UIEquipmentStore.ItemList[UIEquipmentStore.SelectIndex]
	local id = AttributeUtil:GetInfoValue(selectItem, "ID")
	NetClient:Request("Equipment", "Buy", {ID = id}, function(result)
		if result.Success then
			task.wait()
			NetClient:Request("Equipment", "Equip", {ID = id}, function()
				task.wait()
				UIEquipmentStore:Refresh()
				EventManager:Dispatch(EventManager.Define.RefreshEquipment)
			end)
		else
			UIManager:ShowMessage(result.Message)
		end
	end)
end

function UIEquipmentStore:Button_BuyRobux()
	if not UIEquipmentStore.ItemList or #UIEquipmentStore.ItemList == 0 then return end
	local selectItem = UIEquipmentStore.ItemList[UIEquipmentStore.SelectIndex]
	local id = AttributeUtil:GetInfoValue(selectItem, "ID")
	local productKey = AttributeUtil:GetInfoValue(selectItem, "ProductKey")
	IAPClient:Purchase(productKey, function(success)
		if success then
			task.wait()
			NetClient:Request("Equipment", "Equip", {ID = id}, function()
				UIEquipmentStore:Refresh()
				EventManager:Dispatch(EventManager.Define.RefreshEquipment)
			end)
		end
	end)
end

function UIEquipmentStore:Button_Activity()
	if not UIEquipmentStore.ItemList or #UIEquipmentStore.ItemList == 0 then return end
	local selectItem = UIEquipmentStore.ItemList[UIEquipmentStore.SelectIndex]
	local info = AttributeUtil:GetInfo(selectItem)
	local activityKey = info.ActivityKey
	if activityKey then
		UIManager:ShowAndHideOther("UISignActivity", {
			ActivityKey = activityKey
		})
	end
end

function UIEquipmentStore:Button_Newbie()
	if not UIEquipmentStore.ItemList or #UIEquipmentStore.ItemList == 0 then return end
	UIManager:ShowAndHideOther("NewbiePack")
end

return UIEquipmentStore
