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
local TradeClient = require(game.ReplicatedStorage.ScriptAlias.TradeClient)
local TimerManager = require(game.ReplicatedStorage.ScriptAlias.TimerManager)
local TimeUtil = require(game.ReplicatedStorage.ScriptAlias.TimeUtil)

local Define = require(game.ReplicatedStorage.Define)

local UITrade = {}

UITrade.UIRoot = nil
UITrade.SelfFrame = nil
UITrade.OtherFram = nil

UITrade.ItemList = nil

function UITrade:Init(root)
	UITrade.UIRoot = root
	
	UITrade.SelfFrame = Util:GetChildByName(UITrade.UIRoot, "SelfFrame")
	UITrade.OtherFrame = Util:GetChildByName(UITrade.UIRoot, "OtherFrame")
end

local RefreshTimer = nil
local IsCountDown = false
local CountDownTime = Define.Game.TradeCountDown

function UITrade:OnShow(param)
	RefreshTimer = TimerManager:Interval(1, function()
		UITrade:RefreshCountDown()
	end)
end

function UITrade:OnHide()
	NetClient:Request("Trade", "Close", function(result)
		
	end)
	
	RefreshTimer:Stop()
	RefreshTimer = nil
end

function UITrade:Refresh()
	UITrade:RefreshTradeInfo()
	UITrade:RefreshCountDown()
end

function UITrade:RefreshCountDown()
	if not TradeClient.TradeInfo then return end
	local isAllConfirm = TradeClient.SelfInfo.Confirm and TradeClient.OtherInfo.Confirm
	if not IsCountDown and isAllConfirm then
		IsCountDown = true
		CountDownTime = Define.Game.TradeCountDown
	end
	
	if IsCountDown and not isAllConfirm then
		IsCountDown = false
	end
	
	if not IsCountDown then return end
	
	local uiInfo = {
		IsAllConfirm = true,
		CountDown = TimeUtil:FormatMsToMMSS(CountDownTime * 1000)
	}
	
	UIInfo:SetInfo(UITrade.UIRoot, uiInfo)
	
	CountDownTime = CountDownTime - 1
	if CountDownTime <= 0 then
		IsCountDown = false
		NetClient:Request("Trade", "Complete", function(result)
			
		end)
	end
end

function UITrade:RefreshTradeInfo()
	if not TradeClient.TradeInfo then return end
	
	-- Info
	local tradeInfo = TradeClient.TradeInfo
	local selfInfo = TradeClient.SelfInfo
	local otherInfo = TradeClient.OtherInfo
	local uiInfo = {
		OtherDisplayName = otherInfo.DisplayName,
		IsSelfConfirm = selfInfo.Confirm,
		IsOtherConfirm = otherInfo.Confirm,
		IsAllConfirm = otherInfo.Confirm and selfInfo.Confirm,
	}

	UIInfo:SetInfo(UITrade.UIRoot, uiInfo)

	-- Self
	local selfTradeList = TradeClient.SelfInfo.TradeList
	local selfPetInfoList = TradeClient.SelfInfo.PetInfoList
	local selfList = {}
	for _, info in ipairs(selfPetInfoList) do
		info = PetUtil:ProcessPetInfo(info)
		if info.IsLock or info.IsEquip then continue end
		local isSelected = Util:ListContainsWithCondition(selfTradeList, function(selectInfo)
			return selectInfo.InstanceID == info.InstanceID
		end)
		info.IsSelected = isSelected
		table.insert(selfList, info)
	end
	
	selfList = PetUtil:Sort(selfList)
	UITrade.ItemList = UIList:LoadWithInfo(UITrade.SelfFrame, "UITradePetItem", selfList)
	UIList:HandleItemList(UITrade.ItemList, UITrade, "UITradePetItem")

	-- Other
	local otherTradeList = TradeClient.OtherInfo.TradeList
	local otherPetInfoList = TradeClient.OtherInfo.PetInfoList
	local otherList = {}
	for _, selectInfo in ipairs(otherTradeList) do
		local info = Util:ListFind(otherPetInfoList, function(petInfo)
			return petInfo.InstanceID == selectInfo.InstanceID
		end)
		if not info then continue end
		info = PetUtil:ProcessPetInfo(info)
		table.insert(otherList, info)
	end
	
	otherList = PetUtil:Sort(otherList)
	UIList:LoadWithInfo(UITrade.OtherFrame, "UITradePetItem",  otherList)
end

function UITrade:Select(index)
	if not TradeClient.TradeInfo then return end
	if TradeClient.SelfInfo.Confirm then return end
	
	local item = UITrade.ItemList[index]
	AttributeUtil:SetInfoValue(item, "IsSelected", not AttributeUtil:GetInfoValue(item, "IsSelected"))
	local selectList = {}
	for _, item in ipairs(UITrade.ItemList) do
		local isSelected = AttributeUtil:GetInfoValue(item, "IsSelected")
		if isSelected then
			local info = {
				ID = AttributeUtil:GetInfoValue(item, "ID"),
				InstanceID = AttributeUtil:GetInfoValue(item, "InstanceID"),
				UpgradeLevel = AttributeUtil:GetInfoValue(item, "UpgradeLevel"),
			}
			table.insert(selectList, info)
		end	
	end
	
	NetClient:Request("Trade", "UpdateSelectList", { SelectList = selectList }, function(result)
		
	end)
end

function UITrade:Button_Confirm()
	if not TradeClient.TradeInfo then return end
	NetClient:Request("Trade", "UpdateConfirm", { Confirm = true }, function(result)

	end)
end

function UITrade:Button_Cancel()
	if not TradeClient.TradeInfo then return end
	NetClient:Request("Trade", "UpdateConfirm", { Confirm = false }, function(result)

	end)
end

return UITrade
