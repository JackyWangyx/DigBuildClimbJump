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

local Define = require(game.ReplicatedStorage.Define)

UIPetLoot = {}

UIPetLoot.UIRoot = nil
UIPetLoot.Param = nil
UIPetLoot.LootKey = nil
UIPetLoot.EggPrefab = nil

UIPetLoot.ItemList = nil
UIPetLoot.InfoList = {}
UIPetLoot.CacheObjectList = {}

UIPetLoot.ButtonOpenAuto = nil
UIPetLoot.ButtonOpenX9 = nil
UIPetLoot.IsRobuxLoot = false
UIPetLoot.CostCoin = 0
UIPetLoot.CostWins = 0

function UIPetLoot:Init(root)
	UIPetLoot.UIRoot = root
	
	local childList= UIPetLoot.UIRoot:GetDescendants()
	UIPetLoot.ButtonOpenAuto = Util:GetChildByName(UIPetLoot.UIRoot, "Button_OpenAuto", true, childList)
	UIPetLoot.ButtonOpenX9 = Util:GetChildByName(UIPetLoot.UIRoot, "Button_OpenX9", true, childList)
end

function UIPetLoot:OnShow(param)
	
	UIPetLoot.IsRobuxLoot = false
	if param.IsRobuxLoot then
		UIPetLoot.IsRobuxLoot = true
	end
	
	UIPetLoot.Param = param
	UIPetLoot.LootKey = param.LootKey
	UIPetLoot.EggPrefab = param.EggPrefab
	
	UIPetLoot.ItemList = nil
end

function UIPetLoot:OnHide()
	for _, object in pairs(UIPetLoot.CacheObjectList) do
		object:Destroy()
	end
	
	UIPetLoot.CacheObjectList = {}
end

function UIPetLoot:Refresh()
	UIPetLoot:RefreshItemList()
end

function UIPetLoot:RefreshItemList()
	if not UIPetLoot.LootKey then return end
	NetClient:Request("PetLoot", "GetLootList", { LootKey = UIPetLoot.LootKey }, function(infoList)
		if not infoList then return end
		local info = infoList[1]
		UIInfo:SetInfo(UIPetLoot.UIRoot, info)
		UIPetLoot.CostCoin = info.CostCoin
		UIPetLoot.CostWins = info.CostWins
		UIPetLoot.IsRobuxLoot = info.CostRobux > 0
		UIPetLoot.ButtonOpenAuto.Visible = not UIPetLoot.IsRobuxLoot
		UIPetLoot.ButtonOpenX9.Visible = UIPetLoot.IsRobuxLoot

		-- 计算概率
		local totalWeight = Util:ListSum(infoList, function(item) return item.Weight end)
		for _, info in ipairs(infoList) do
			local probability = info.Weight / totalWeight
			info.Probability = probability 
			info.DisplayProbability = Util:FormatProbability(info.Probability)
		end
		
		infoList = Util:ListSort(infoList, {
			function(info) return -info.Probability end
		})
		
		UIPetLoot.ItemList = UIList:LoadWithInfo(UIPetLoot.UIRoot, "UIPetLootItem", infoList)
		
		for _, item in ipairs(UIPetLoot.ItemList)  do
			local petID = AttributeUtil:GetInfoValue(item, "PetID")
			local petData = ConfigManager:GetData("Pet", petID)
			AttributeUtil:SetData(item, petData)
			UIInfo:SetInfo(item, petData)
		end
		
		--UIList:HandleItemList(UIPetLoot.ItemList, UIPetLoot, "UIPetItem")
		UIListSelect:HandleSelectMany(UIPetLoot.ItemList, function(item)
			
		end)
	end)
	
end

function UIPetLoot:SelectItem(index)
	
end

function UIPetLoot:CheckAccount(count)
	if not UIPetLoot.IsRobuxLoot then
		if UIPetLoot.CostCoin > 0 then
			local remainCoin = NetClient:RequestWait("Account", "GetCoin")
			if remainCoin < UIPetLoot.CostCoin * count then
				UIManager:ShowMessage(Define.Message.CoinNotEnough)
				return false
			else
				return true
			end
		elseif UIPetLoot.CostWins > 0 then
			local remainWins = NetClient:RequestWait("Account", "GetWins")
			if remainWins < UIPetLoot.CostWins * count then
				UIManager:ShowMessage(Define.Message.WinsNotEnough)
				return false
			else
				return true
			end
		end
	else
		return true
	end
end

function UIPetLoot:Button_OpenX1()
	if not UIPetLoot.ItemList then return end
	local check = UIPetLoot:CheckAccount(1)
	if not check then return end
	check = PetUtil:CheckPackage(1)
	if not check then return end
	
	if UIPetLoot.IsRobuxLoot then
		IAPClient:Purchase("BrainrotPetEggX1", nil, function(success)
			if success then
				UIPetLoot:OpenLootImpl(1, false, 1)
			end
		end)
	else
		UIPetLoot:OpenLootImpl(1, false, 1)
	end
end

function UIPetLoot:Button_OpenX3()
	if not UIPetLoot.ItemList then return end
	local check = UIPetLoot:CheckAccount(3)
	if not check then return end
	check = PetUtil:CheckPackage(3)
	if not check then return end
	
	if UIPetLoot.IsRobuxLoot then
		IAPClient:Purchase("BrainrotPetEggX3", nil, function(success)
			if success then
				UIPetLoot:OpenLootImpl(3, false, 1)
			end
		end)
	else
		IAPClient:CheckHasGamePass("HatchX3", function(isPurchased)
			if isPurchased then
				UIPetLoot:OpenLootImpl(3, false, 1)
			else
				IAPClient:Purchase("HatchX3", function(success)
					UIPetLoot:Refresh()
				end)
			end
		end)
	end
end

function UIPetLoot:Button_OpenX9()
	if not UIPetLoot.ItemList then return end
	local check = UIPetLoot:CheckAccount(9)
	if not check then return end
	check = PetUtil:CheckPackage(9)
	if not check then return end
	
	if UIPetLoot.IsRobuxLoot then
		IAPClient:Purchase("BrainrotPetEggX9", nil, function(success)
			if success then
				UIPetLoot:OpenLootImpl(3, true, 3)
			end
		end)
	else
		IAPClient:CheckHasGamePass("HatchX3", function(isPurchased)
			if isPurchased then
				UIPetLoot:OpenLootImpl(1, true, 9)
			else
				IAPClient:Purchase("HatchX3", function(success)
					UIPetLoot:Refresh()
				end)
			end
		end)	
	end
end

function UIPetLoot:Button_OpenAuto()
	if not UIPetLoot.ItemList then return end
	IAPClient:CheckHasGamePass("AutoHatch", function(isPurchased)
		if isPurchased then
			IAPClient:CheckHasGamePass("HatchX3", function(isPurchasedOpen3)
				if isPurchasedOpen3 then
					UIPetLoot:OpenLootImpl(3, true, -1)
				else
					UIPetLoot:OpenLootImpl(1, true, -1)
				end
			end)	
		else
			IAPClient:Purchase("AutoHatch", function(success)
				UIPetLoot:Refresh()
			end)
		end
	end)	
end

function UIPetLoot:OpenLootImpl(count, openAuto, times)
	local selectList = UIListSelect:GetSelectList(UIPetLoot.ItemList)
	local deleteIDList = Util:ListSelect(selectList, function(item) return AttributeUtil:GetInfoValue(item, "PetID") end)
	if not times then
		times = -1
	end
	local param = {}
	param.LootKey = UIPetLoot.LootKey
	param.EggPrefab = UIPetLoot.EggPrefab
	param.LootCount = count
	param.OpenAuto = openAuto
	param.IsRobuxLoot = UIPetLoot.IsRobuxLoot
	param.DeleteIDList = deleteIDList
	param.IsRewardLoot = false
	param.Times = times
	
	UIManager:ShowAndHideOther("PetLootResult", param)
end

return UIPetLoot
