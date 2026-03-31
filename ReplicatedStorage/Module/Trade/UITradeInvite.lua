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

local Define = require(game.ReplicatedStorage.Define)

local UITradeInvite = {}

UITradeInvite.UIRoot = nil

function UITradeInvite:Init(root)
	UITradeInvite.UIRoot = root
end

local TimeOutTimer = nil

function UITradeInvite:OnShow(param)
	TimeOutTimer = TimerManager:After(Define.Game.TradeInviteTimeOut, function()
		NetClient:Request("Trade", "RejectInvite", function(result)
			TimeOutTimer = nil
			UIManager:Hide("TradeInvite")
		end)
	end)
end

function UITradeInvite:OnHide()
	if TimeOutTimer then
		TimeOutTimer:Stop()
		TimeOutTimer = nil
	end
end

function UITradeInvite:Refresh()
	if not TradeClient.TradeInfo then return end
	local uiInfo = {
		DisplayName = TradeClient.OtherInfo.DisplayName
	}
	
	UIInfo:SetInfo(UITradeInvite.UIRoot, uiInfo)
end

function UITradeInvite:Button_Accept()
	if not TradeClient.TradeInfo then return end
	NetClient:Request("Trade", "AcceptInvite", function(result)
		UIManager:Hide("TradeInvite")
	end)
end

function UITradeInvite:Button_Reject()
	if not TradeClient.TradeInfo then return end
	NetClient:Request("Trade", "RejectInvite", function(result)
		UIManager:Hide("TradeInvite")
	end)
end

return UITradeInvite
