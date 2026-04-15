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
local PetUtil = require(game.ReplicatedStorage.ScriptAlias.PetUtil)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)

local Define = require(game.ReplicatedStorage.Define)

local UIPetPack = {}

UIPetPack.UIRoot = nil
UIPetPack.InfoPart = nil
UIPetPack.ItemList = nil
UIPetPack.SelectIndex = 1
UIPetPack.DeleteMode = false
UIPetPack.DeleteButton = nil
UIPetPack.DeleteLab = nil

UIPetPack.InfoList = nil
UIPetPack.PackageMax = 0
UIPetPack.EquipMax = 0

UIPetPack.ButtonCraft = nil
UIPetPack.ButtonCraftRobux = nil

UIPetPack.ButtonEquip = nil
UIPetPack.ButtonAddEquipMax = nil
UIPetPack.ButtonAddPackageMax = nil

function UIPetPack:Init(root)
	UIPetPack.UIRoot = root
	
	local childList= UIPetPack.UIRoot:GetDescendants()
	UIPetPack.InfoPart = Util:GetChildByName(UIPetPack.UIRoot, "InfoLab", childList)
	UIPetPack.DeleteButton = Util:GetChildByName(UIPetPack.UIRoot, "Button_Delete", childList)
	UIPetPack.DeleteLab = Util:GetChildByName(UIPetPack.UIRoot, "DeleteLab", childList)
	UIPetPack.ButtonCraft = Util:GetChildByName(UIPetPack.UIRoot, "Button_Craft", childList)
	UIPetPack.ButtonCraftRobux = Util:GetChildByName(UIPetPack.UIRoot, "Button_CraftRobux", childList)
	UIPetPack.ButtonAddEquipMax = Util:GetChildByName(UIPetPack.UIRoot, "Button_AddEquipMax", childList)
	UIPetPack.ButtonAddPackageMax = Util:GetChildByName(UIPetPack.UIRoot, "Button_AddPackageMax", childList)
	UIPetPack.ButtonEquip = Util:GetChildByName(UIPetPack.UIRoot, "Button_Equip", childList)
end

function UIPetPack:OnShow()
	UIPetPack.SelectIndex = 1
	UIPetPack.DeleteMode = false
	UIPetPack.ItemList = nil
end

function UIPetPack:OnHide()
	
end

function UIPetPack:Refresh()
	UIPetPack:RefreshList()
	UIPetPack:RefreshDelete()
end

function UIPetPack:RefreshList()
	PetUtil:GetSorttedPackageList(function(infoList)
		UIPetPack.InfoList = infoList
		UIPetPack.ItemList = UIList:LoadWithInfoData(UIPetPack.UIRoot, "UIPetItem", infoList, "Pet")
		UIList:HandleItemList(UIPetPack.ItemList, UIPetPack, "UIPetItem")
		
		UIPetPack:RefreshInfo()
	end)	
end

function UIPetPack:RefreshInfo()
	UIPetPack:SelectItem(UIPetPack.SelectIndex)
	
	NetClient:RequestQueue({
		{ Module = "Pet", Action = "GetPackageMax" },
		{ Module = "Pet", Action = "IsPackageMaxLevel" },
		{ Module = "Pet", Action = "GetEquipMax" },
		{ Module = "Pet", Action = "IsEquipMaxLevel" },
	}, function(result)
		local packageMax = result[1]
		UIPetPack.PackageMax = packageMax
		if UIPetPack.ItemList then
			UIInfo:SetValue(UIPetPack.UIRoot, "PackageCount", #UIPetPack.ItemList)
		else
			UIInfo:SetValue(UIPetPack.UIRoot, "PackageCount", 0)
		end
		
		UIInfo:SetValue(UIPetPack.UIRoot, "PackageMax", packageMax)
		local isPackageMax = result[2]
		UIPetPack.ButtonAddPackageMax.Visible = not isPackageMax
		
		local equipMax = result[3]
		UIPetPack.EquipMax = equipMax
		local equipCount = Util:ListCount(UIPetPack.ItemList, function(item)
			local isEquip = AttributeUtil:GetInfoValue(item, "IsEquip")
			return isEquip
		end)
		
		local isEquipMax = result[4]
		UIPetPack.ButtonAddEquipMax.Visible = not isEquipMax
		
		UIInfo:SetValue(UIPetPack.UIRoot, "EquipCount", equipCount)
		UIInfo:SetValue(UIPetPack.UIRoot, "EquipMax", equipMax)
		
		local isEquipFull = equipCount >= equipMax
		UIPetPack.ButtonEquip.Visible = not isEquipFull
	end)
end

function UIPetPack:RefreshDelete()
	UIPetPack.DeleteButton.Visible = not UIPetPack.DeleteMode
	UIPetPack.DeleteLab.Visible = UIPetPack.DeleteMode
	if not UIPetPack.DeleteMode then
		UIPetPack:SelectAll(false)
	end
end

-- Select Item
function UIPetPack:SelectItem(index)
	if not UIPetPack.ItemList then return end
	if #UIPetPack.ItemList == 0 then
		UIPetPack.InfoPart.Visible = false
		return
	else
		UIPetPack.InfoPart.Visible = true
	end
	
	if index > #UIPetPack.ItemList then index = #UIPetPack.ItemList end
	UIPetPack.SelectIndex = index
	local item = UIPetPack.ItemList[index]
	local data = AttributeUtil:GetData(item)
	UIInfo:SetInfo(UIPetPack.InfoPart, data)
	local info = AttributeUtil:GetInfo(item)
	UIInfo:SetInfo(UIPetPack.InfoPart, info)

	local isLock = info.IsLock;
	if UIPetPack.DeleteMode and not isLock then
		local isSelect = not info.IsSelect
		UIListSelect:SetSelect(item, isSelect)
	else
		UIListSelect:SetSelect(item, false)
	end
	
	NetClient:RequestQueue({
		{ Module = "Pet", Action = "CheckCanCraft", Param = { InstanceID = info.InstanceID }},
		{ Module = "Pet", Action = "CheckCraftMaxLevel", Param = { InstanceID = info.InstanceID }},
		{ Module = "Pet", Action = "GetSamePetList", Param = { InstanceID = info.InstanceID } }
	}, function(result)
		local canCraft = result[1] and not info.IsLock
		UIPetPack.ButtonCraft.Visible = true
		
		local isCraftMaxLevel = result[2]
		local canCraftRobux = not isCraftMaxLevel and not info.IsLock
		UIPetPack.ButtonCraftRobux.Visible = true
		
		local samePetList = result[3]
		local count = 0
		if samePetList then
			count = #samePetList
		end
		UIInfo:SetValue(UIPetPack.InfoPart, "SamePetCount", count)
	end)
end

-- Equip
function UIPetPack:Button_Equip()
	if not UIPetPack.ItemList or #UIPetPack.ItemList == 0 then return end
	local selectItem = UIPetPack.ItemList[UIPetPack.SelectIndex]
	local instanceID = AttributeUtil:GetInfoValue(selectItem, "InstanceID")
	NetClient:Request("Pet", "Equip", {InstanceID = instanceID}, function(result)
		if result  then
			AttributeUtil:SetInfoValue(selectItem, "IsEquip", true)
			UIInfo:SetValue(selectItem, "IsEquip", true)
			UIPetPack:RefreshInfo()
		end
	end)
end

function UIPetPack:Button_UnEquip()
	if not UIPetPack.ItemList or #UIPetPack.ItemList == 0 then return end
	local selectItem = UIPetPack.ItemList[UIPetPack.SelectIndex]
	local instanceID = AttributeUtil:GetInfoValue(selectItem, "InstanceID")
	NetClient:Request("Pet", "UnEquip", {InstanceID = instanceID}, function(result)
		if result  then
			AttributeUtil:SetInfoValue(selectItem, "IsEquip", false)
			UIInfo:SetValue(selectItem, "IsEquip", false)
			UIPetPack:RefreshInfo()
		end
	end)
end

function UIPetPack:Button_UnEquipAll()
	NetClient:Request("Pet", "UnEquipAll", function(result)
		if result  then
			UIPetPack:Refresh()
		end
	end)
end

function UIPetPack:Button_EquipBest()
	if not UIPetPack.ItemList or #UIPetPack.ItemList == 0 then return end
	NetClient:Request("Pet", "EquipBest", function(result)
		if result  then
			UIPetPack:Refresh()
		end
	end)
end

-- Package
function UIPetPack:Button_AddEquipMax()
	IAPClient:Purchase("AddPetEquip", function(result)
		UIPetPack:Refresh()
	end)
end

function UIPetPack:Button_AddPackageMax()
	IAPClient:Purchase("AddPetPackage", function(result)
		UIPetPack:Refresh()
	end)
end

-- 进入删除模式
function UIPetPack:Button_Delete()
	if not UIPetPack.ItemList or #UIPetPack.ItemList == 0 then return end
	UIPetPack:SelectAll(false)
	UIPetPack:RefreshInfo()
	UIPetPack.DeleteMode = true
	UIPetPack:RefreshDelete()
end

-- 退出删除模式
function UIPetPack:Button_CancelDelete()
	if not UIPetPack.ItemList or #UIPetPack.ItemList == 0 then return end
	UIPetPack:SelectAll(false)
	UIPetPack.DeleteMode = false
	UIPetPack:RefreshDelete()
	UIPetPack:RefreshInfo()
end

function UIPetPack:Button_SelectAll()
	if not UIPetPack.ItemList or #UIPetPack.ItemList == 0 then return end
	UIPetPack:SelectAll(true)
end

-- 删除选中
function UIPetPack:Button_DeleteSelect()
	if not UIPetPack.ItemList or #UIPetPack.ItemList == 0 then return end
	UIConfirm:Show("Confirm", Define.Message.ConfirmDeletePet, "Confirm", "Cancel", function(result)
		if not result then return end
		local selectList = UIListSelect:GetSelectList(UIPetPack.ItemList)
		if #selectList == 0 then
			return
		end
		
		local requestParam = {
			InstanceIDList ={}
		}

		for _, selectItem in pairs(selectList) do
			local instanceID = AttributeUtil:GetInfoValue(selectItem, "InstanceID")
			table.insert(requestParam.InstanceIDList, instanceID)
		end
	
		NetClient:Request("Pet", "DeleteAll", requestParam, function()
			for _, selectItem in pairs(selectList) do
				Util:ListRemove(UIPetPack.ItemList, selectItem)
				selectItem:Destroy()
			end
			
			UIPetPack.SelectIndex = 1
			UIPetPack.DeleteMode = false
			UIPetPack:Refresh()
		end)
	end)
end

-- Select Delete
function UIPetPack:SelectAll(isSelect)
	if not UIPetPack.ItemList or #UIPetPack.ItemList == 0 then return end
	for _, item in pairs(UIPetPack.ItemList) do
		local isLock = AttributeUtil:GetInfoValue(item, "IsLock")
		if isLock then
			isSelect = false
		end
		
		UIListSelect:SetSelect(item, isSelect)
	end
end

-- Craft

function UIPetPack:Button_Craft()
	if not UIPetPack.ItemList or #UIPetPack.ItemList == 0 then return end
	local selectItem = UIPetPack.ItemList[UIPetPack.SelectIndex]
	local instanceID = AttributeUtil:GetInfoValue(selectItem, "InstanceID")
	NetClient:Request("Pet", "CheckCanCraft", { InstanceID = instanceID }, function(result)
		if result then
			NetClient:Request("Pet", "Craft", { InstanceID = instanceID }, function(result)
				if result then
					UIPetPack:Refresh()
				end
			end)
		else
			UIManager:ShowMessage(Define.Message.MaxLevel)
		end
	end)
end

function UIPetPack:Button_CraftRobux()
	if not UIPetPack.ItemList or #UIPetPack.ItemList == 0 then return end
	local selectItem = UIPetPack.ItemList[UIPetPack.SelectIndex]
	local instanceID = AttributeUtil:GetInfoValue(selectItem, "InstanceID")
	NetClient:Request("Pet", "CheckCraftMaxLevel", { InstanceID = instanceID }, function(result)
		if not result then
			IAPClient:Purchase("CraftPet", { InstanceID = instanceID }, function(result)
				if result then
					UIPetPack:Refresh()
				end
			end)
		else
			UIManager:ShowMessage(Define.Message.MaxLevel)
		end
	end)
end

function UIPetPack:Button_CraftAll()
	if not UIPetPack.ItemList or #UIPetPack.ItemList == 0 then return end
	NetClient:Request("Pet", "CraftAll", function(result)
		if result then
			UIPetPack:Refresh()
		end
	end)
end

-- Other Page

function UIPetPack:Button_PropPack()
	UIManager:ShowAndHideOther("PropPack")
end

return UIPetPack
