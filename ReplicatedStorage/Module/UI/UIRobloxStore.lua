local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIPropList = require(game.ReplicatedStorage.ScriptAlias.UIPropList)
local PetUtil = require(game.ReplicatedStorage.ScriptAlias.PetUtil)
local BigNumber = require(game.ReplicatedStorage.ScriptAlias.BigNumber)
local UIIndexManager = require(game.ReplicatedStorage.ScriptAlias.UIIndexManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local Define = require(game.ReplicatedStorage.Define)

local UIRobloxStore = {}

UIRobloxStore.UIRoot = nil
UIRobloxStore.UIPropFrame = nil
UIRobloxStore.TextInput = nil -- [新增] 存储输入框引用
UIRobloxStore.UICoinsFrame = nil

local LimitedTimeToolButtonList = {
	{
		ButtonName = "Button_LimitedTime_Tool1",
		ProductKey = "ProductStoreTool26",
		ToolID = 26,
	},
	{
		ButtonName = "Button_LimitedTime_Tool2",
		ProductKey = "ProductStoreTool27",
		ToolID = 27,
	},
}

local LimitedTimeEquipmentButtonList = {
	{
		ButtonName = "Button_LimitedTime_Equipment1",
		ProductKey = "ProductStoreEquipment11",
		EquipmentID = 11,
	},
	{
		ButtonName = "Button_LimitedTime_Equipment2",
		ProductKey = "ProductStoreEquipment12",
		EquipmentID = 12,
	},
}

UIRobloxStore.IAPCoinList = {
	[1] = {
		Text = "Text_IAP_Coin_1",
		Value = 500,
	},
	[2] = {
		Text = "Text_IAP_Coin_2",
		Value = 10000,
	},
	[3] = {
		Text = "Text_IAP_Coin_3",
		Value = 100000,
	},
	[4] = {
		Text = "Text_IAP_Coin_4",
		Value = 1,
	},
	[5] = {
		Text = "Text_IAP_Coin_5",
		Value = 1,
	},
	[6] = {
		Text = "Text_IAP_Coin_6",
		Value = 1,
	},
	[7] = {
		Text = "Text_IAP_Coin_7",
		Value = 1,
	},
}

local function GetClickableButton(root, buttonName)
	local button = Util:GetChildByName(root, buttonName, true)
	if not button then return nil end
	if button:IsA("GuiButton") then return button end
	return Util:GetChildByType(button, "GuiButton", true)
end

local function PurchaseLimitedTimeTool(toolID, productKey)
	IAPClient:Purchase(productKey, function(success)
		if not success then return end

		task.wait()
		NetClient:Request("Tool", "Equip", { ID = toolID }, function()
			EventManager:Dispatch(EventManager.Define.RefreshTool)
		end)
	end)
end

local function CheckBeforeChangeEquipment()
	local status = NetClient:RequestWait("Player", "GetStatus")
	if status == Define.PlayerStatus.Training then
		local trainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)
		trainingMachine:End()
	end
end

local function PurchaseLimitedTimeEquipment(equipmentID, productKey)
	IAPClient:Purchase(productKey, function(success)
		if not success then return end

		CheckBeforeChangeEquipment()
		task.wait()
		NetClient:Request("Equipment", "Equip", { ID = equipmentID }, function()
			EventManager:Dispatch(EventManager.Define.RefreshEquipment)
		end)
	end)
end

local function BindLimitedTimeButtons(root)
	for _, info in ipairs(LimitedTimeToolButtonList) do
		local button = GetClickableButton(root, info.ButtonName)
		if button then
			local toolID = info.ToolID
			local productKey = info.ProductKey
			UIButton:Handle(button, function()
				PurchaseLimitedTimeTool(toolID, productKey)
			end)
		end
	end

	for _, info in ipairs(LimitedTimeEquipmentButtonList) do
		local button = GetClickableButton(root, info.ButtonName)
		if button then
			local equipmentID = info.EquipmentID
			local productKey = info.ProductKey
			UIButton:Handle(button, function()
				PurchaseLimitedTimeEquipment(equipmentID, productKey)
			end)
		end
	end
end

function UIRobloxStore:Init(root)
	UIRobloxStore.UIRoot = root
	UIRobloxStore.UIPropFrame = UIIndexManager:GetChildByName(root, "PropFrame")
	UIPropList:Init(UIRobloxStore.UIPropFrame)

	-- [新增] 初始化兑换码输入框
	UIRobloxStore.TextInput = UIIndexManager:GetChildByName(root, "TextInput_RedeemCode")
	UIRobloxStore:ClearInput()
	
	UIRobloxStore.UICoinsFrame = UIIndexManager:GetChildByName(root, "CoinsFrame")
	BindLimitedTimeButtons(root)
end

function UIRobloxStore:OnShow(param)
	-- [新增] 打开界面时清空输入框
	UIRobloxStore:ClearInput()
end

function UIRobloxStore:OnHide()

end

function UIRobloxStore:Refresh()
	UIPropList:Refresh()
	UIRobloxStore:RefreshCoinList()
	BindLimitedTimeButtons(UIRobloxStore.UIRoot)
end

function UIRobloxStore:RefreshCoinList()
	local getCoinFactor = NetClient:RequestWait("Player", "GetGamePropertyValue", { Property = Define.PlayerProperty.GET_COIN_FACTOR })
	for index, data in ipairs(UIRobloxStore.IAPCoinList) do
		local textPart = Util:GetChildByName(UIRobloxStore.UICoinsFrame, data.Text)
		if textPart then
			local value = math.round(data.Value * getCoinFactor)
			local text = BigNumber:Format(value)
			textPart.Text = "$" .. text
		end
	end
end

-- [新增] 兑换码功能区域 ----------------------------------------------------

function UIRobloxStore:ClearInput()
	if UIRobloxStore.TextInput then
		UIRobloxStore.TextInput.Text = ""
	end
end

function UIRobloxStore:Button_Redeem()
	if not UIRobloxStore.TextInput then return end

	local redeemCode = UIRobloxStore.TextInput.Text
	if Util:IsStrEmpty(redeemCode) then
		return
	end

	NetClient:Request("Redeem", "GetReward", { RedeemCode = redeemCode },  function(result)
		if result.Success then
			local rewardList = result.RewardList
			for _, data in ipairs(rewardList) do
				UIManager:ShowMessageWithIcon(data.Icon, "Got "..data.Description)
				task.wait()
			end
		else
			UIManager:ShowMessage(result.Message)
		end
		UIRobloxStore:ClearInput()
	end)
end

-- -----------------------------------------------------------------------

-- LimitedTime Pet

function UIRobloxStore:Button_LimitedTime_Pet1()
	local check = PetUtil:CheckPackage(1)
	if not check then return end

	IAPClient:Purchase("ProductStorePet246", function(result)
	end)
end

function UIRobloxStore:Button_LimitedTime_Pet2()
	local check = PetUtil:CheckPackage(1)
	if not check then return end

	IAPClient:Purchase("ProductStorePet251", function(result)
	end)
end

function UIRobloxStore:Button_LimitedTime_Pet3()
	local check = PetUtil:CheckPackage(1)
	if not check then return end

	IAPClient:Purchase("ProductStorePet256", function(result)
	end)
end


-- LimitedTime Tool

function UIRobloxStore:Button_LimitedTime_Tool1()
	PurchaseLimitedTimeTool(26, "ProductStoreTool26")
end

function UIRobloxStore:Button_LimitedTime_Tool2()
	PurchaseLimitedTimeTool(27, "ProductStoreTool27")
end

-- LimitedTime Equipment

function UIRobloxStore:Button_LimitedTime_Equipment1()
	PurchaseLimitedTimeEquipment(11, "ProductStoreEquipment11")
end

function UIRobloxStore:Button_LimitedTime_Equipment2()
	PurchaseLimitedTimeEquipment(12, "ProductStoreEquipment12")
end


-- PetLoot Smile

local PetRobuxLootSmileParam = {
	LootKey = "PetLoot101",
	EggPrefab = "Egg/Egg101"
}

function UIRobloxStore:Button_PetLootSmileX1()
	local check = PetUtil:CheckPackage(1)
	if not check then return end

	local uiInfo = UIManager:GetPage("UIPetLoot")
	local uiPetLoot = uiInfo.Script

	uiPetLoot.IsRobuxLoot = true
	uiPetLoot.Param = PetRobuxLootSmileParam
	uiPetLoot.LootKey = PetRobuxLootSmileParam.LootKey
	uiPetLoot.EggPrefab = PetRobuxLootSmileParam.EggPrefab
	IAPClient:Purchase("SlimePetEggX1", nil, function(result)
		if result then
			task.delay(0.1, function()
				UIManager:Hide("UIRobloxStore")
				uiPetLoot:OpenLootImpl(1, false, 1)
			end)
		end
	end)
end

function UIRobloxStore:Button_PetLootSmileX3()
	local check = PetUtil:CheckPackage(1)
	if not check then return end

	local uiInfo = UIManager:GetPage("UIPetLoot")
	local uiPetLoot = uiInfo.Script

	uiPetLoot.IsRobuxLoot = true
	uiPetLoot.Param = PetRobuxLootSmileParam
	uiPetLoot.LootKey = PetRobuxLootSmileParam.LootKey
	uiPetLoot.EggPrefab = PetRobuxLootSmileParam.EggPrefab
	IAPClient:Purchase("SlimePetEggX3", nil, function(result)
		if result then
			task.delay(0.1, function()
				UIManager:Hide("UIRobloxStore")
				uiPetLoot:OpenLootImpl(3, false, 1)
			end)
		end
	end)
end

function UIRobloxStore:Button_PetLootSmileX9()
	local check = PetUtil:CheckPackage(1)
	if not check then return end

	local uiInfo = UIManager:GetPage("UIPetLoot")
	local uiPetLoot = uiInfo.Script

	uiPetLoot.IsRobuxLoot = true
	uiPetLoot.Param = PetRobuxLootSmileParam
	uiPetLoot.LootKey = PetRobuxLootSmileParam.LootKey
	uiPetLoot.EggPrefab = PetRobuxLootSmileParam.EggPrefab
	IAPClient:Purchase("SlimePetEggX9", nil, function(result)
		if result then
			task.delay(0.1, function()
				UIManager:Hide("UIRobloxStore")
				uiPetLoot:OpenLootImpl(3, true, 3)
			end)
		end
	end)
end

-- PetLoot Brainrot

local PetRobuxLootBrainrotParam = {
	LootKey = "PetLoot102",
	EggPrefab = "Egg/Egg102"
}

function UIRobloxStore:Button_PetLootBrainrotX1()
	local check = PetUtil:CheckPackage(1)
	if not check then return end

	local uiInfo = UIManager:GetPage("UIPetLoot")
	local uiPetLoot = uiInfo.Script

	uiPetLoot.IsRobuxLoot = true
	uiPetLoot.Param = PetRobuxLootBrainrotParam
	uiPetLoot.LootKey = PetRobuxLootBrainrotParam.LootKey
	uiPetLoot.EggPrefab = PetRobuxLootBrainrotParam.EggPrefab
	IAPClient:Purchase("BrainrotPetEggX1", nil, function(result)
		if result then
			task.delay(0.1, function()
				UIManager:Hide("UIRobloxStore")
				uiPetLoot:OpenLootImpl(1, false, 1)
			end)
		end
	end)
end

function UIRobloxStore:Button_PetLootBrainrotX3()
	local check = PetUtil:CheckPackage(1)
	if not check then return end

	local uiInfo = UIManager:GetPage("UIPetLoot")
	local uiPetLoot = uiInfo.Script

	uiPetLoot.IsRobuxLoot = true
	uiPetLoot.Param = PetRobuxLootBrainrotParam
	uiPetLoot.LootKey = PetRobuxLootBrainrotParam.LootKey
	uiPetLoot.EggPrefab = PetRobuxLootBrainrotParam.EggPrefab
	IAPClient:Purchase("BrainrotPetEggX3", nil, function(result)
		if result then
			task.delay(0.1, function()
				UIManager:Hide("UIRobloxStore")
				uiPetLoot:OpenLootImpl(3, false, 1)
			end)
		end
	end)
end

function UIRobloxStore:Button_PetLootBrainrotX9()
	local check = PetUtil:CheckPackage(1)
	if not check then return end

	local uiInfo = UIManager:GetPage("UIPetLoot")
	local uiPetLoot = uiInfo.Script

	uiPetLoot.IsRobuxLoot = true
	uiPetLoot.Param = PetRobuxLootBrainrotParam
	uiPetLoot.LootKey = PetRobuxLootBrainrotParam.LootKey
	uiPetLoot.EggPrefab = PetRobuxLootBrainrotParam.EggPrefab
	IAPClient:Purchase("BrainrotPetEggX9", nil, function(result)
		if result then
			task.delay(0.1, function()
				UIManager:Hide("UIRobloxStore")
				uiPetLoot:OpenLootImpl(3, true, 3)
			end)
		end
	end)
end

return UIRobloxStore
