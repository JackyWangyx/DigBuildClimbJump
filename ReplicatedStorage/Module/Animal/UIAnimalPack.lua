local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local AttributeUtil = require(game.ReplicatedStorage.ScriptAlias.AttributeUtil)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local UIListSelect = require(game.ReplicatedStorage.ScriptAlias.UIListSelect)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local UIConfirm = require(game.ReplicatedStorage.ScriptAlias.UIConfirm)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local AnimalUtil = require(game.ReplicatedStorage.ScriptAlias.AnimalUtil)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local Define = require(game.ReplicatedStorage.Define)

local UIAnimalPack = {}

UIAnimalPack.UIRoot = nil
UIAnimalPack.InfoPart = nil
UIAnimalPack.ItemList = nil
UIAnimalPack.SelectIndex = 1
UIAnimalPack.DeleteMode = false
UIAnimalPack.DeleteButton = nil
UIAnimalPack.DeleteLab = nil

UIAnimalPack.InfoList = nil
UIAnimalPack.PackageMax = 0
UIAnimalPack.EquipMax = 0

UIAnimalPack.ButtonEquip = nil
--UIAnimalPack.ButtonAddEquipMax = nil
UIAnimalPack.ButtonAddPackageMax = nil

function UIAnimalPack:Init(root)
	UIAnimalPack.UIRoot = root
	
	local childList= UIAnimalPack.UIRoot:GetDescendants()
	UIAnimalPack.InfoPart = Util:GetChildByName(UIAnimalPack.UIRoot, "InfoLab", childList)
	UIAnimalPack.DeleteButton = Util:GetChildByName(UIAnimalPack.UIRoot, "Button_Delete", childList)
	UIAnimalPack.DeleteLab = Util:GetChildByName(UIAnimalPack.UIRoot, "DeleteLab", childList)
	UIAnimalPack.ButtonAddPackageMax = Util:GetChildByName(UIAnimalPack.UIRoot, "Button_AddPackageMax", childList)
	UIAnimalPack.ButtonEquip = Util:GetChildByName(UIAnimalPack.UIRoot, "Button_Equip", childList)
end

function UIAnimalPack:OnShow()
	UIAnimalPack.InfoPart.Visible = false
	UIAnimalPack.SelectIndex = 1
	UIAnimalPack.DeleteMode = false
	UIAnimalPack.ItemList = nil
end

function UIAnimalPack:OnHide()
	
end

function UIAnimalPack:Refresh()
	UIAnimalPack:RefreshList()
	UIAnimalPack:RefreshDelete()
end

function UIAnimalPack:RefreshList()
	AnimalUtil:GetSorttedPackageList(function(infoList)
		UIAnimalPack.InfoList = infoList
		UIAnimalPack.ItemList = UIList:LoadWithInfoData(UIAnimalPack.UIRoot, "UIAnimalItem", infoList, "Animal")
		UIList:HandleItemList(UIAnimalPack.ItemList, UIAnimalPack, "UIAnimalItem")
		
		UIAnimalPack:RefreshInfo()
		
		if #UIAnimalPack.InfoList > 0 then
			UIAnimalPack.InfoPart.Visible = true
		end
	end)	
end

function UIAnimalPack:RefreshInfo()
	UIAnimalPack:SelectItem(UIAnimalPack.SelectIndex)
	
	NetClient:RequestQueue({
		{ Module = "Animal", Action = "GetPackageMax" },
		{ Module = "Animal", Action = "IsPackageMaxLevel" },
		{ Module = "Animal", Action = "GetEquipMax" },
		--{ Module = "Animal", Action = "IsEquipMaxLevel" },
	}, function(result)
		local packageMax = result[1]
		UIAnimalPack.PackageMax = packageMax
		if UIAnimalPack.ItemList then
			UIInfo:SetValue(UIAnimalPack.UIRoot, "PackageCount", #UIAnimalPack.ItemList)
		else
			UIInfo:SetValue(UIAnimalPack.UIRoot, "PackageCount", 0)
		end
		
		UIInfo:SetValue(UIAnimalPack.UIRoot, "PackageMax", packageMax)
		local isPackageMax = result[2]
		UIAnimalPack.ButtonAddPackageMax.Visible = not isPackageMax
		
		local equipMax = result[3]
		UIAnimalPack.EquipMax = equipMax
		local equipCount = Util:ListCount(UIAnimalPack.ItemList, function(item)
			local isEquip = AttributeUtil:GetInfoValue(item, "IsEquip")
			return isEquip
		end)
		
		--local isEquipMax = result[4]
		--UIAnimalPack.ButtonAddEquipMax.Visible = not isEquipMax
		
		UIInfo:SetValue(UIAnimalPack.UIRoot, "EquipCount", equipCount)
		UIInfo:SetValue(UIAnimalPack.UIRoot, "EquipMax", equipMax)
		
		local isEquipFull = equipCount >= equipMax
		UIAnimalPack.ButtonEquip.Visible = not isEquipFull
	end)
end

function UIAnimalPack:RefreshDelete()
	UIAnimalPack.DeleteButton.Visible = not UIAnimalPack.DeleteMode
	UIAnimalPack.DeleteLab.Visible = UIAnimalPack.DeleteMode
	if not UIAnimalPack.DeleteMode then
		UIAnimalPack:SelectAll(false)
	end
end

-- Select Item
function UIAnimalPack:SelectItem(index)
	if not UIAnimalPack.ItemList then return end
	if #UIAnimalPack.ItemList == 0 then
		UIAnimalPack.InfoPart.Visible = false
		return
	else
		UIAnimalPack.InfoPart.Visible = true
	end
	
	if index > #UIAnimalPack.ItemList then index = #UIAnimalPack.ItemList end
	UIAnimalPack.SelectIndex = index
	local item = UIAnimalPack.ItemList[index]
	local data = AttributeUtil:GetData(item)
	UIInfo:SetInfo(UIAnimalPack.InfoPart, data)
	local info = AttributeUtil:GetInfo(item)
	UIInfo:SetInfo(UIAnimalPack.InfoPart, info)

	local isLock = info.IsLock;
	if UIAnimalPack.DeleteMode and not isLock then
		local isSelect = not info.IsSelect
		UIListSelect:SetSelect(item, isSelect)
	else
		UIListSelect:SetSelect(item, false)
	end
end

-- Equip
function UIAnimalPack:Button_Equip()
	if not UIAnimalPack.ItemList or #UIAnimalPack.ItemList == 0 then return end
	local selectItem = UIAnimalPack.ItemList[UIAnimalPack.SelectIndex]
	local instanceID = AttributeUtil:GetInfoValue(selectItem, "InstanceID")
	NetClient:Request("Animal", "Equip", {InstanceID = instanceID}, function(result)
		if result  then
			AttributeUtil:SetInfoValue(selectItem, "IsEquip", true)
			UIInfo:SetValue(selectItem, "IsEquip", true)
			UIAnimalPack:RefreshInfo()
			
			EventManager:Dispatch(EventManager.Define.RefreshAnimal)
		end
	end)
end

function UIAnimalPack:Button_UnEquip()
	if not UIAnimalPack.ItemList or #UIAnimalPack.ItemList == 0 then return end
	local selectItem = UIAnimalPack.ItemList[UIAnimalPack.SelectIndex]
	local instanceID = AttributeUtil:GetInfoValue(selectItem, "InstanceID")
	NetClient:Request("Animal", "UnEquip", {InstanceID = instanceID}, function(result)
		if result  then
			AttributeUtil:SetInfoValue(selectItem, "IsEquip", false)
			UIInfo:SetValue(selectItem, "IsEquip", false)
			UIAnimalPack:RefreshInfo()
			
			EventManager:Dispatch(EventManager.Define.RefreshAnimal)
		end
	end)
end

function UIAnimalPack:Button_UnEquipAll()
	NetClient:Request("Animal", "UnEquipAll", function(result)
		if result  then
			UIAnimalPack:Refresh()
			
			EventManager:Dispatch(EventManager.Define.RefreshAnimal)
		end
	end)
end

function UIAnimalPack:Button_EquipBest()
	if not UIAnimalPack.ItemList or #UIAnimalPack.ItemList == 0 then return end
	local infoList = UIAnimalPack.InfoList
	if not infoList then return end

	AnimalUtil:SortDesc(infoList)

	local equipInfoList = Util:ListFindMany(infoList, UIAnimalPack.EquipMax)
	local param = { InstanceIDList = {}}
	for _, info in ipairs(equipInfoList) do
		table.insert(param.InstanceIDList, info.InstanceID)
	end

	NetClient:Request("Animal", "EquipBest", param, function(result)
		if result  then
			UIAnimalPack:Refresh()
			EventManager:Dispatch(EventManager.Define.RefreshAnimal)
		end
	end)
end

-- Package
function UIAnimalPack:Button_AddEquipMax()
	IAPClient:Purchase("AddAnimalEquip", function(result)
		UIAnimalPack:Refresh()
	end)
end

function UIAnimalPack:Button_AddPackageMax()
	IAPClient:Purchase("AddAnimalPackage", function(result)
		UIAnimalPack:Refresh()
	end)
end

-- 进入删除模式
function UIAnimalPack:Button_Delete()
	if not UIAnimalPack.ItemList or #UIAnimalPack.ItemList == 0 then return end
	UIAnimalPack:SelectAll(false)
	UIAnimalPack:RefreshInfo()
	UIAnimalPack.DeleteMode = true
	UIAnimalPack:RefreshDelete()
end

-- 退出删除模式
function UIAnimalPack:Button_CancelDelete()
	if not UIAnimalPack.ItemList or #UIAnimalPack.ItemList == 0 then return end
	UIAnimalPack:SelectAll(false)
	UIAnimalPack.DeleteMode = false
	UIAnimalPack:RefreshDelete()
	UIAnimalPack:RefreshInfo()
end

function UIAnimalPack:Button_SelectAll()
	if not UIAnimalPack.ItemList or #UIAnimalPack.ItemList == 0 then return end
	UIAnimalPack:SelectAll(true)
end

-- 删除选中
function UIAnimalPack:Button_DeleteSelect()
	if not UIAnimalPack.ItemList or #UIAnimalPack.ItemList == 0 then return end
	UIConfirm:Show("Confirm", Define.Message.ConfirmDeleteAnimal, "Confirm", "Cancel", function(result)
		if not result then return end
		local selectList = UIListSelect:GetSelectList(UIAnimalPack.ItemList)
		if #selectList == 0 then
			return
		end
		
		local requestParam = {
			InstanceIDList ={}
		}

		for _, selectItem in ipairs(selectList) do
			local instanceID = AttributeUtil:GetInfoValue(selectItem, "InstanceID")
			table.insert(requestParam.InstanceIDList, instanceID)
		end
	
		NetClient:Request("Animal", "DeleteAll", requestParam, function()
			for _, selectItem in ipairs(selectList) do
				Util:ListRemove(UIAnimalPack.ItemList, selectItem)
				selectItem:Destroy()
			end
			
			UIAnimalPack.SelectIndex = 1
			UIAnimalPack.DeleteMode = false
			UIAnimalPack:Refresh()
			
			EventManager:Dispatch(EventManager.Define.RefreshAnimal)
		end)
	end)
end

-- Select Delete
function UIAnimalPack:SelectAll(isSelect)
	if not UIAnimalPack.ItemList or #UIAnimalPack.ItemList == 0 then return end
	for _, item in ipairs(UIAnimalPack.ItemList) do
		local isLock = AttributeUtil:GetInfoValue(item, "IsLock")
		if isLock then
			isSelect = false
		end
		
		UIListSelect:SetSelect(item, isSelect)
	end
end

return UIAnimalPack
