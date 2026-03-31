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

local UIPetUpgrade = {}

UIPetUpgrade.UIRoot = nil
UIPetUpgrade.Mode = 1
UIPetUpgrade.SelectInstanceID = 1

UIPetUpgrade.PackageFrame = nil
UIPetUpgrade.ItemList = nil

UIPetUpgrade.SelectFrame = nil
UIPetUpgrade.SelectList = nil

UIPetUpgrade.UpgradeFrame = nil
UIPetUpgrade.ImageSpin = nil

UIPetUpgrade.SuccessFrame = nil
UIPetUpgrade.FailFrame = nil

function UIPetUpgrade:Init(root)
	UIPetUpgrade.UIRoot = root
	
	local childList= UIPetUpgrade.UIRoot:GetDescendants()
	UIPetUpgrade.PackageFrame = Util:GetChildByName(UIPetUpgrade.UIRoot, "PackageFrame", childList)
	UIPetUpgrade.SelectFrame = Util:GetChildByName(UIPetUpgrade.UIRoot, "SelectFrame", childList)
	UIPetUpgrade.UpgradeFrame = Util:GetChildByName(UIPetUpgrade.UIRoot, "UpgradeFrame", childList)
	UIPetUpgrade.SuccessFrame = Util:GetChildByName(UIPetUpgrade.UIRoot, "SuccessFrame", childList)
	UIPetUpgrade.FailFrame = Util:GetChildByName(UIPetUpgrade.UIRoot, "FailFrame", childList)	
	UIPetUpgrade.ImageSpin = Util:GetChildByName(UIPetUpgrade.UIRoot, "Image_Spin", childList)
end

function UIPetUpgrade:OnShow()
	UIPetUpgrade.Mode = 1
	UIPetUpgrade.ItemList = nil
	UIPetUpgrade.SelectList = nil
end

function UIPetUpgrade:OnHide()

end

function UIPetUpgrade:Refresh()
	UIPetUpgrade:RefreshTab()
end

function UIPetUpgrade:RefreshInfo()
	
end

function UIPetUpgrade:RefreshTab()
	UIPetUpgrade.PackageFrame.Visible = UIPetUpgrade.Mode == 1
	UIPetUpgrade.SelectFrame.Visible = UIPetUpgrade.Mode == 2
	UIPetUpgrade.UpgradeFrame.Visible = UIPetUpgrade.Mode == 3
	
	if UIPetUpgrade.Mode == 1 then UIPetUpgrade:RefreshPackage()
	elseif UIPetUpgrade.Mode == 2 then UIPetUpgrade:RefreshUpgradeList()
	elseif UIPetUpgrade.Mode == 3 then UIPetUpgrade:RefreshUpgradeSpin()	
	end
	
	if UIPetUpgrade.Mode == 1 then
		UIPetUpgrade.SelectList = nil
	end
	
	UIPetUpgrade.SuccessFrame.Visible = false
	UIPetUpgrade.FailFrame.Visible = false
end

-- Step 1
function UIPetUpgrade:RefreshPackage()
	PetUtil:GetUpgradableList(nil, function(infoList)
		UIPetUpgrade.ItemList = UIList:LoadWithInfoData(UIPetUpgrade.PackageFrame, "UIPetUpgradeItem", infoList, "Pet")
		UIList:HandleItemList(UIPetUpgrade.ItemList, UIPetUpgrade, "UIPetItem")
	end)
end

function UIPetUpgrade:SelectItem(index)
	if not UIPetUpgrade.ItemList or #UIPetUpgrade.ItemList == 0 then return end
	if UIPetUpgrade.Mode == 1 then
		local selectItem = UIPetUpgrade.ItemList[index]
		UIPetUpgrade.SelectInstanceID = AttributeUtil:GetInfoValue(selectItem, "InstanceID")
		UIPetUpgrade.Mode = 2
		UIPetUpgrade:Refresh()
	elseif UIPetUpgrade.Mode == 2 then
		
	end
end

-- Step 2
function UIPetUpgrade:RefreshUpgradeList()
	PetUtil:GetUpgradableList(UIPetUpgrade.SelectInstanceID, function(infoList)
		UIList:ClearChild(UIPetUpgrade.SelectFrame)
		UIPetUpgrade.SelectList = UIList:LoadWithInfoData(UIPetUpgrade.SelectFrame, "UIPetUpgradeItem", infoList, "Pet")
		UIList:HandleItemList(UIPetUpgrade.SelectList, UIPetUpgrade, "UIPetItem")
		UIListSelect:HandleSelectMany(UIPetUpgrade.SelectList, function(item)
			UIPetUpgrade:SelectUpradeItem(item)
		end)

		UIInfo:SetValue(UIPetUpgrade.SelectFrame, "Chance", "0%")
	end)
end

function UIPetUpgrade:SelectUpradeItem(item)
	if not UIPetUpgrade.SelectList or #UIPetUpgrade.ItemList == 0 then return end
	local selectList = UIListSelect:GetSelectList(UIPetUpgrade.SelectList)
	local chance = 0.2 * #selectList
	if chance > 1 then chance = 1 end
	local chanceText = tostring(math.floor(chance * 100)).."%"
	UIInfo:SetValue(UIPetUpgrade.SelectFrame, "Chance", chanceText)
end

function UIPetUpgrade:Button_BackStep1()
	UIPetUpgrade.Mode = 1
	UIPetUpgrade:Refresh()
end

function UIPetUpgrade:Button_Upgrade()
	if not UIPetUpgrade.SelectList or #UIPetUpgrade.ItemList == 0 then return end
	local selectList = UIListSelect:GetSelectList(UIPetUpgrade.SelectList)
	if #selectList == 0 then
		return
	end
	
	UIPetUpgrade.Mode = 3
	UIPetUpgrade:Refresh()
end

-- Step 3
function UIPetUpgrade:RefreshUpgradeSpin()
	UIPetUpgrade.ImageSpin.Rotation = 0
	task.wait(0.5)
	local selectItemList = UIListSelect:GetSelectList(UIPetUpgrade.SelectList)
	local instanceIDList = Util:ListSelect(selectItemList, function(item)
		return AttributeUtil:GetInfoValue(item, "InstanceID")
	end)

	NetClient:Request("Pet", "Upgrade", { InstanceIDList = instanceIDList}, function(result)
		local spinIndex = result.Result and 1 or math.random(2, 5)
		TweenUtil:Spin(UIPetUpgrade.ImageSpin, 5, spinIndex, function()
			task.wait(0.5)
			UIPetUpgrade.UpgradeFrame.Visible = false
			if result.Result then
				UIPetUpgrade.SuccessFrame.Visible = true
				local info = result.PetInfo
				info = PetUtil:ProcessPetInfo(info)
				local data = ConfigManager:GetData("Pet", info.ID)
				UIInfo:SetInfo(UIPetUpgrade.SuccessFrame, data)
				UIInfo:SetInfo(UIPetUpgrade.SuccessFrame, info)
			else
				UIPetUpgrade.FailFrame.Visible = true
			end

			task.wait(1)
			UIPetUpgrade.Mode = 1
			UIPetUpgrade:Refresh()
		end)
	end)
end

return UIPetUpgrade
