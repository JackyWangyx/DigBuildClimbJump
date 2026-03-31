local UIButtonOpen = require(game.ReplicatedStorage.ScriptAlias.UIButtonOpen)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local AttributeUtil = require(game.ReplicatedStorage.ScriptAlias.AttributeUtil)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local UIConditionChecker = require(game.ReplicatedStorage.ScriptAlias.UIConditionChecker)
local ConditionUtil = require(game.ReplicatedStorage.ScriptAlias.ConditionUtil)
local TweenUtil = require(game.ReplicatedStorage.ScriptAlias.TweenUtil)
local UIAccountInfo = require(game.ReplicatedStorage.ScriptAlias.UIAccountInfo)

local UIGamePassState = require(game.ReplicatedStorage.ScriptAlias.UIGamePassState)
local UIPropStateList = require(game.ReplicatedStorage.ScriptAlias.UIPropStateList)
local UIBuffInfo = require(game.ReplicatedStorage.ScriptAlias.UIBuffInfo)

--local RunnerGameManager = require(game.ReplicatedStorage.ScriptAlias.RunnerGameManager)
local UIClimbTowerGameInfo = require(game.ReplicatedStorage.ScriptAlias.UIClimbTowerGameInfo)
--local UIAnimalEquip = require(game.ReplicatedStorage.ScriptAlias.UIAnimalEquip)
local UIClimbTowerAutoPlay = require(game.ReplicatedStorage.ScriptAlias.UIClimbTowerAutoPlay)

local Define = require(game.ReplicatedStorage.Define)

local UIMain = {}

UIMain.UIRoot = nil
UIMain.MainFrame = nil

UIMain.NotifyRebirth = nil
UIMain.TradeConditon = nil

UIMain.UIPropBuffFrame = nil
UIMain.UIGamePassFrame = nil

function UIMain:Init(root)
	UIMain.UIRoot = root

	local childList = UIMain.UIRoot:GetDescendants()
	UIMain.MainFrame = Util:GetChildByName(UIMain.UIRoot, "MainFrame", true, childList)
	
	UIClimbTowerGameInfo:Init(root)
	UIClimbTowerAutoPlay:Init(root)
	
	--UIAnimalEquip:Init(root)
	UIBuffInfo:Init(root)
	
	UIMain.UIPropBuffFrame = Util:GetChildByName(UIMain.UIRoot, "UIPropBuffFrame", true, childList)
	UIPropStateList:Init(UIMain.UIPropBuffFrame)
	UIMain.UIGamePassFrame = Util:GetChildByName(UIMain.UIRoot, "UIGamePassFrame", true, childList)
	UIGamePassState:Init(UIMain.UIGamePassFrame)
	
	UIMain.TradeConditon = Util:GetChildByName(UIMain.UIRoot, "ConditionChecker_TradeUnlock", true, childList)
	if UIMain.TradeConditon then
		UIConditionChecker:Handle(UIMain.TradeConditon, UIConditionChecker.Define.TradeUnlock, nil, nil, EventManager.Define.RefreshRebirth)
	end
	
	UIAccountInfo:Init(root)
	
	EventManager:Listen(EventManager.Define.PetLootStart, function()
		UIMain.MainFrame.Visible = false
	end)

	EventManager:Listen(EventManager.Define.PetLootEnd, function()
		UIMain.MainFrame.Visible = true
	end)
	
	UIMain.UIAnimalEquipFrame = Util:GetChildByName(root, "UIAnimalEquip")
	EventManager:Listen(EventManager.Define.GameEnter, function()
		UIMain.UIAnimalEquipFrame.Visible = false
	end)

	EventManager:Listen(EventManager.Define.GameLeave, function()
		UIMain.UIAnimalEquipFrame.Visible = true
	end)
	
	--local AutoPlayFrame = Util:GetChildByName(UIMain.UIRoot, "AutoPlayFrame", true, childList)
	UIClimbTowerAutoPlay:Init(UIMain.UIRoot)
end

function UIMain:Refresh()
	--UIMain:RefreshNewbiePack()
end

function UIMain:OnShow()
	UIMain:ShowButton()
	--UIMain:RefreshNewbiePack()
end

function UIMain:OnHide()

end

function UIMain:HideButton()
	if UIMain.UIRoot.MainFrame.Left then
		UIMain.UIRoot.MainFrame.Left.Visible = false
	end
	
	if UIMain.UIRoot.MainFrame.Right then
		UIMain.UIRoot.MainFrame.Right.Visible = false
	end
end

function UIMain:ShowButton()
	if UIMain.UIRoot.MainFrame.Left then
		UIMain.UIRoot.MainFrame.Left.Visible = true
	end
	
	if UIMain.UIRoot.MainFrame.Right then
		UIMain.UIRoot.MainFrame.Right.Visible = true
	end
end

-- Game
function UIMain:Button_ExitGame()
	local info = UIClimbTowerAutoPlay:GetInfo()
	if info.IsAutoGame then
		UIClimbTowerAutoPlay:EndAutoGame()
	end
	
	--RunnerGameManager:Exit()
end

-- Menu
function UIMain:Button_PetPack()
	UIManager:ShowAndHideOther("PetPack")
end

function UIMain:Button_ToolStore()
	UIManager:ShowAndHideOther("ToolStore")
end

function UIMain:Button_DailyReward()
	UIManager:ShowAndHideOther("DailyReward")
end

function UIMain:Button_LuckyWheel()
	UIManager:ShowAndHideOther("LuckyWheel")
end

function UIMain:Button_Rebirth()
	UIManager:ShowAndHideOther("Rebirth")
end

function UIMain:Button_RobloxStore()
	UIManager:ShowAndHideOther("RobloxStore")
end

function UIMain:Button_TrailStore()
	UIManager:ShowAndHideOther("TrailStore")
end

function UIMain:Button_PartnerStore()
	UIManager:ShowAndHideOther("PartnerStore")
end

function UIMain:Button_AnimalPack()
	UIManager:ShowAndHideOther("AnimalPack")
end

function UIMain:Button_AnimalStore()
	UIManager:ShowAndHideOther("AnimalStore")
end

function UIMain:Button_Theme()
	UIManager:ShowAndHideOther("Theme")
end

-- Sign
function UIMain:Button_SignDaily15()
	UIManager:ShowAndHideOther("SignDaily15")
end

function UIMain:Button_SignDaily30()
	UIManager:ShowAndHideOther("SignDaily30")
end

function UIMain:Button_SignDaily7()
	UIManager:ShowAndHideOther("SignDaily7")
end

function UIMain:Button_SignOnline()
	UIManager:ShowAndHideOther("SignOnline")
end

function UIMain:Button_Trade()
	local tradeUnlock = ConditionUtil:Check(ConditionUtil.Define.TradeUnlock)
	if tradeUnlock then
		local tradeClient = require(game.ReplicatedStorage.ScriptAlias.TradeClient)
		tradeClient:Start()
	end
end

function UIMain:Button_RedeemCode()
	UIManager:ShowAndHideOther("RedeemCode")
end

function UIMain:Button_NewbiePack ()
	UIManager:ShowAndHideOther("NewbiePack")
end

--function UIMain:RefreshNewbiePack()
--	local button = Util:GetChildByName(UIMain.UIRoot, "Button_NewbiePack")
--	NetClient:Request("IAP", "GetPackageCount", { ID = 3 }, function(count)
--		if count > 0 then
--			button.Visible = false				
--		else
--			button.Visible = true
--		end
--	end)
--end

-- Buff
function UIMain:Button_BuffInvite()
	local friendManager = require(game.ReplicatedStorage.ScriptAlias.FriendManager)
	friendManager:ClientInvite()
	
	UIBuffInfo.UIBuffFriendOnline:Refresh()
end

function UIMain:Button_BuffPremium()
	local robloxUtil = require(game.ReplicatedStorage.ScriptAlias.RobloxUtil)
	robloxUtil:OpenPremium()
	
	UIBuffInfo.UIBuffPremium:Refresh()
end

function UIMain:Button_BuffOnline()
	UIBuffInfo.UIBuffOnline:Refresh()
end

function UIMain:Button_Achievement()
	UIManager:ShowAndHideOther("UIQuestAchievement")
end

function UIMain:Button_Season()
	UIManager:ShowAndHideOther("UIQuestSeason")
end

return UIMain
