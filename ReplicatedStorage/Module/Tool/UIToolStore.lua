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

local UIToolStore = {}

UIToolStore.UIRoot = nil
UIToolStore.InfoPart = nil

UIToolStore.ItemList = nil
UIToolStore.SelectIndex = 1

function UIToolStore:Init(root)
	UIToolStore.UIRoot = root
	UIToolStore.InfoPart = Util:GetChildByName(UIToolStore.UIRoot, "InfoLab")
end

function UIToolStore:OnShow(param)
	UIToolStore.InfoPart.Visible = false
	UIToolStore.SelectIndex = 1
	UIToolStore.ItemList = nil
end

function UIToolStore:OnHide()

end

function UIToolStore:Refresh()
	UIToolStore:RefreshItemList()
end

function UIToolStore:RefreshItemList()
	NetClient:Request("Tool", "GetPackageList", function(infoList)
		local showInfoList = {}
		for _, info in ipairs(infoList) do
			local data = ConfigManager:GetData("Tool", info.ID)
			local isRobuxTool = not Util:IsStrEmpty(data.ProductKey)
			--print(isRobuxTool, data)
			if not info.IsBuy and isRobuxTool then
				continue
			end
			
			Util:TableMerge(info, data)
			table.insert(showInfoList, info)
		end

		ConfigManager:FliterDataSource("Tool", showInfoList)
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

		UIToolStore:MoveAfterCondition(showInfoList, function(info)
			return info.ID == 1
		end, function(info)
			return info.CostRobux > 0
		end)
		
		UIToolStore.ItemList = UIList:LoadWithInfoData(UIToolStore.UIRoot, "UIToolItem", showInfoList, "Tool")
		UIList:HandleItemList(UIToolStore.ItemList, UIToolStore, "UIToolItem")
		
		UIToolStore:RefreshInfo()
		
		if #showInfoList > 0 then
			UIToolStore.InfoPart.Visible = true
		end		
	end)
end

function UIToolStore:MoveAfterCondition(data, conditionA, conditionB)
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

function UIToolStore:RefreshInfo()
	UIToolStore:SelectItem(UIToolStore.SelectIndex)
end

function UIToolStore:SelectItem(index)
	if not UIToolStore.ItemList then return end
	if #UIToolStore.ItemList == 0 then
		UIToolStore.InfoPart.Visible = false
		return
	else
		UIToolStore.InfoPart.Visible = true
	end

	if index > #UIToolStore.ItemList then index = #UIToolStore.ItemList end
	UIToolStore.SelectIndex = index
	local item = UIToolStore.ItemList[index]
	local data = AttributeUtil:GetData(item)
	UIInfo:SetInfo(UIToolStore.InfoPart, data)
	local info = AttributeUtil:GetInfo(item)
	UIInfo:SetInfo(UIToolStore.InfoPart, info)
	
	--local infoNewbiePart = Util:GetChildByName(UIToolStore.InfoPart, "Info_CostNewbie")
	--if infoNewbiePart then
	--	infoNewbiePart.Visible = data.ID == 20
	--end	
end

function UIToolStore:Button_Equip()
	if not UIToolStore.ItemList or #UIToolStore.ItemList == 0 then return end
	UIToolStore:CheckBeforeChangeTool()
	local selectItem = UIToolStore.ItemList[UIToolStore.SelectIndex]
	local id = AttributeUtil:GetInfoValue(selectItem, "ID")
	NetClient:Request("Tool", "Equip", {ID = id}, function()
		UIToolStore:Refresh()
		EventManager:Dispatch(EventManager.Define.RefreshTool)
	end)
end

function UIToolStore:Button_UnEquip()
	if not UIToolStore.ItemList or #UIToolStore.ItemList == 0 then return end
	UIToolStore:CheckBeforeChangeTool()
	local selectItem = UIToolStore.ItemList[UIToolStore.SelectIndex]
	local id = AttributeUtil:GetInfoValue(selectItem, "ID")
	NetClient:Request("Tool", "UnEquip", function()
		UIToolStore:Refresh()
		EventManager:Dispatch(EventManager.Define.RefreshTool)
	end)
end

function UIToolStore:CheckBeforeChangeTool()
	if not UIToolStore.ItemList or #UIToolStore.ItemList == 0 then return end
	local status = NetClient:RequestWait("Player", "GetStatus")
	if status == Define.PlayerStatus.Training then
		local trainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)
		trainingMachine:End()
	end
end

function UIToolStore:Button_Buy()
	if not UIToolStore.ItemList or #UIToolStore.ItemList == 0 then return end
	local selectItem = UIToolStore.ItemList[UIToolStore.SelectIndex]
	local id = AttributeUtil:GetInfoValue(selectItem, "ID")
	NetClient:Request("Tool", "Buy", {ID = id}, function(result)
		if result.Success then
			task.wait()
			NetClient:Request("Tool", "Equip", {ID = id}, function()
				task.wait()
				UIToolStore:Refresh()
				EventManager:Dispatch(EventManager.Define.RefreshTool)
			end)
		else
			UIManager:ShowMessage(result.Message)
		end
	end)
end

function UIToolStore:Button_BuyRobux()
	if not UIToolStore.ItemList or #UIToolStore.ItemList == 0 then return end
	local selectItem = UIToolStore.ItemList[UIToolStore.SelectIndex]
	local id = AttributeUtil:GetInfoValue(selectItem, "ID")
	local productKey = AttributeUtil:GetInfoValue(selectItem, "ProductKey")
	IAPClient:Purchase(productKey, function(success)
		if success then
			task.wait()
			NetClient:Request("Tool", "Equip", {ID = id}, function()
				UIToolStore:Refresh()
				EventManager:Dispatch(EventManager.Define.RefreshTool)
			end)
		end
	end)
end

function UIToolStore:Button_Activity()
	if not UIToolStore.ItemList or #UIToolStore.ItemList == 0 then return end
	local selectItem = UIToolStore.ItemList[UIToolStore.SelectIndex]
	local info = AttributeUtil:GetInfo(selectItem)
	local activityKey = info.ActivityKey
	if activityKey then
		UIManager:ShowAndHideOther("UISignActivity", {
			ActivityKey = activityKey
		})
	end
end

function UIToolStore:Button_Newbie()
	if not UIToolStore.ItemList or #UIToolStore.ItemList == 0 then return end
	UIManager:ShowAndHideOther("NewbiePack")
end

return UIToolStore
