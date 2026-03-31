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

local Define = require(game.ReplicatedStorage.Define)

local UITradeSelectTarget = {}

UITradeSelectTarget.UIRoot = nil
UITradeSelectTarget.ItemList = nil

function UITradeSelectTarget:Init(root)
	UITradeSelectTarget.UIRoot = root
	
	PlayerManager:HandlePlayerAddRemove(function(player)
		
	end, function(player)
		
	end)
end

function UITradeSelectTarget:OnShow(param)
end

function UITradeSelectTarget:OnHide()
	if TradeClient.CurrentTrade then
		NetClient:Request("Trade", "CancelInvite", function()	
			
		end)
	end
end

function UITradeSelectTarget:Refresh()
	NetClient:Request("Trade", "GetPlayerList", function(result)
		UITradeSelectTarget.ItemList = UIList:LoadWithInfo(UITradeSelectTarget.UIRoot, "UITradePlayerItem", result)
		UIList:HandleItemList(UITradeSelectTarget.ItemList, UITradeSelectTarget, "UITradePlayerItem")
		UIList:HadnlePlayerHeadIconAsync(UITradeSelectTarget.ItemList)
	end)
	
	NetClient:Request("Trade", "GetEnable", function(result)
		local uiInfo = {
			IsSelfTradeEnable = result
		}
		
		UIInfo:SetInfo(UITradeSelectTarget.UIRoot, uiInfo)
	end)
end

function UITradeSelectTarget:Select(index)
	local item = UITradeSelectTarget.ItemList[index]
	local targetPlayerID = AttributeUtil:GetInfoValue(item, "UserID")
	NetClient:Request("Trade", "Invite", { TargetPlayerID = targetPlayerID }, function(trade)
		if trade then
			UIManager:ShowMessage(Define.Message.TradeInviteSend)
			TradeClient:SetTradeInfo(trade)
			UITradeSelectTarget:Refresh()
		end	
	end)
end

function UITradeSelectTarget:Button_TradeEnable()
	NetClient:Request("Trade", "Switch", function(result)
		UITradeSelectTarget:Refresh()
	end)
end

function UITradeSelectTarget:Button_TradeDisable()
	NetClient:Request("Trade", "Switch", function(result)
		UITradeSelectTarget:Refresh()
	end)
end

return UITradeSelectTarget
