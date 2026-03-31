local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local AttributeUtil = require(game.ReplicatedStorage.ScriptAlias.AttributeUtil)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local UIListSelect = require(game.ReplicatedStorage.ScriptAlias.UIListSelect)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local PetUtil = require(game.ReplicatedStorage.ScriptAlias.PetUtil)
local ActivityUtil = require(game.ReplicatedStorage.ScriptAlias.ActivityUtil)

local Define = require(game.ReplicatedStorage.Define)

local UISignActivity = {}

UISignActivity.UIRoot = nil
UISignActivity.ItemList = nil

UISignActivity.ActivityKey = nil
UISignActivity.ActivityData = nil

local PetLootParam = nil

function UISignActivity:Init(root)
	UISignActivity.UIRoot = root
end

function UISignActivity:OnShow(param)
	UISignActivity.ActivityKey = param.ActivityKey
	UISignActivity.ActivityData  = ActivityUtil:GetData(param.ActivityKey)
	
	PetLootParam = {
		LootKey = "PetLoot" .. UISignActivity.ActivityKey,
		EggPrefab = UISignActivity.ActivityData.EggPrefab,
	}
end

function UISignActivity:OnHide()

end

function UISignActivity:Refresh()
	NetClient:Request("Sign", "GetDailyList", { 
		Key = "SignDaily" .. UISignActivity.ActivityKey, 
		ActivityKey = UISignActivity.ActivityKey, 
		IsActivity = true 
	}, function(infoList)
		UISignActivity.ItemList = UIList:LoadWithInfo(UISignActivity.UIRoot, nil, infoList)
		UIList:HandleItemList(UISignActivity.ItemList, UISignActivity, "UISignItem")
	end)
end

--------------------------------------------------------------------------------------------------------
-- Pet Loot

function UISignActivity:Button_PetLootX1()
	local check = PetUtil:CheckPackage(1)
	if not check then return end

	local uiInfo = UIManager:GetPage("UIPetLoot")
	local uiPetLoot = uiInfo.Script

	uiPetLoot.IsRobuxLoot = true
	uiPetLoot.Param = PetLootParam
	uiPetLoot.LootKey = PetLootParam.LootKey
	uiPetLoot.EggPrefab = PetLootParam.EggPrefab
	IAPClient:Purchase("PetEggX1" .. UISignActivity.ActivityKey, nil, function(result)
		if result then
			task.delay(0.1, function()
				UIManager:Hide("UISignActivity")
				uiPetLoot:OpenLootImpl(1, false, 1)
			end)
		end
	end)
end

function UISignActivity:Button_PetLootX3()
	local check = PetUtil:CheckPackage(3)
	if not check then return end

	local uiInfo = UIManager:GetPage("UIPetLoot")
	local uiPetLoot = uiInfo.Script

	uiPetLoot.IsRobuxLoot = true
	uiPetLoot.Param = PetLootParam
	uiPetLoot.LootKey = PetLootParam.LootKey
	uiPetLoot.EggPrefab = PetLootParam.EggPrefab
	IAPClient:Purchase("PetEggX3" .. UISignActivity.ActivityKey, nil, function(result)
		if result then
			task.delay(0.1, function()
				UIManager:Hide("UISignActivity")
				uiPetLoot:OpenLootImpl(3, false, 1)
			end)
		end
	end)
end

function UISignActivity:Button_PetLootX9()
	local check = PetUtil:CheckPackage(9)
	if not check then return end

	local uiInfo = UIManager:GetPage("UIPetLoot")
	local uiPetLoot = uiInfo.Script

	uiPetLoot.IsRobuxLoot = true
	uiPetLoot.Param = PetLootParam
	uiPetLoot.LootKey = PetLootParam.LootKey
	uiPetLoot.EggPrefab = PetLootParam.EggPrefab
	IAPClient:Purchase("PetEggX9" .. UISignActivity.ActivityKey, nil, function(result)
		if result then
			task.delay(0.1, function()
				UIManager:Hide("UISignActivity")
				uiPetLoot:OpenLootImpl(3, true, 3)
			end)
		end
	end)
end

--------------------------------------------------------------------------------------------------------
-- Sign

function UISignActivity:Claim(index)
	if not UISignActivity.ItemList then return end
	NetClient:Request("Sign", "GetDailyReward", { 
		Key = "SignDaily" .. UISignActivity.ActivityKey, 
		ctivityKey = UISignActivity.ActivityKey, 
		ID = index, 
		IsActivity = true  
	}, function(rewardList)
		UISignActivity:Refresh()
		for _, data in ipairs(rewardList) do
			UIManager:ShowMessageWithIcon(data.Icon, "Got "..data.Description)
			task.wait()
		end
		
		EventManager:Dispatch(EventManager.Define.RefreshSignDaily)
	end)
end

function  UISignActivity:Button_ClaimAll(index)
	if not UISignActivity.ItemList then return end
	NetClient:Request("Sign", "CheckDailyComplete", { Key = "SignDaily" .. UISignActivity.ActivityKey }, function(isComplete)
		if isComplete then 
			return 
		end
		
		IAPClient:Purchase("SignDailyGetAll" .. UISignActivity.ActivityKey, function(success)
			if not success then return end
			NetClient:Request("Sign", "GetAllDailyReward", { Key = "SignDaily" .. UISignActivity.ActivityKey }, function(rewardList)
				UISignActivity:Refresh()
				for _, data in ipairs(rewardList) do
					UIManager:ShowMessageWithIcon(data.Icon, "Got "..data.Description)
					task.wait(0.1)
				end
				
				EventManager:Dispatch(EventManager.Define.RefreshSignOnline)
			end)
		end)
	end)
end

return UISignActivity
