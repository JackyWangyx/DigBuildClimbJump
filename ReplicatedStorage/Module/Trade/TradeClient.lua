local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local Define = require(game.ReplicatedStorage.Define)

local TradeClient = {}

TradeClient.TradeInfo = nil
TradeClient.SelfInfo = nil
TradeClient.OtherInfo = nil
TradeClient.IsFrom = false

function TradeClient:Init()
	TradeClient:Clear()
	EventManager:Listen(Define.Event.TradeInvite, function(param)
		TradeClient:OnInvite(param)
	end)
	EventManager:Listen(Define.Event.TradeRejectInvite, TradeClient.OnRejectInvite)
	EventManager:Listen(Define.Event.TradeAcceptInvite, function(param)
		TradeClient:OnAcceptInvite(param)
	end)
	EventManager:Listen(Define.Event.TradeCancelInvite, TradeClient.OnCancelInvite)
	EventManager:Listen(Define.Event.TradeUpdate, function(param)
		TradeClient:OnUpdate(param)
	end)
	
	EventManager:Listen(Define.Event.TradePackageFull, TradeClient.OnPackageFull)
	EventManager:Listen(Define.Event.TradeClose, TradeClient.OnClose)
	EventManager:Listen(Define.Event.TradeComplete, TradeClient.OnComplete)
end

function TradeClient:Clear()
	TradeClient.TradeInfo = nil
	TradeClient.SelfInfo = nil
	TradeClient.OtherInfo = nil
end

function TradeClient:Start()
	UIManager:ShowAndHideOther("UITradeSelectTarget")
end

function TradeClient:OnInvite(tradeInfo)
	TradeClient:SetTradeInfo(tradeInfo)
	UIManager:Show("TradeInvite")
end

function TradeClient:SetTradeInfo(tradeInfo)
	TradeClient.TradeInfo = tradeInfo
	local fromPlayer = PlayerManager:GetPlayerById(tradeInfo.FromPlayerID)
	local toPlayer = PlayerManager:GetPlayerById(tradeInfo.ToPlayerID)
	local isFrom = game.Players.LocalPlayer.UserId == fromPlayer.UserId
	
	TradeClient.IsFrom = isFrom
	local selfPlayer = nil
	local otherPlayer = nil
	
	if isFrom then
		selfPlayer = fromPlayer
		otherPlayer = toPlayer
	else
		selfPlayer = toPlayer
		otherPlayer = fromPlayer
	end
	
	TradeClient.SelfInfo = {
		Player = selfPlayer,
		UserID = selfPlayer.UserId,
		Name = selfPlayer.Name,
		DisplayName = selfPlayer.DisplayName,
	}
	
	TradeClient.OtherInfo = {
		Player = otherPlayer,
		UserID = otherPlayer.UserId,
		Name = otherPlayer.Name,
		DisplayName = otherPlayer.DisplayName,
	}
	
	if isFrom then
		TradeClient.SelfInfo.Confirm = TradeClient.TradeInfo.FromConfirm
		TradeClient.SelfInfo.PetInfoList = TradeClient.TradeInfo.FromPetInfoList
		TradeClient.SelfInfo.TradeList = TradeClient.TradeInfo.FromTradeList
		TradeClient.OtherInfo.Confirm = TradeClient.TradeInfo.ToConfirm
		TradeClient.OtherInfo.PetInfoList = TradeClient.TradeInfo.ToPetInfoList
		TradeClient.OtherInfo.TradeList = TradeClient.TradeInfo.ToTradeList
	else
		TradeClient.SelfInfo.Confirm = TradeClient.TradeInfo.ToConfirm
		TradeClient.SelfInfo.PetInfoList = TradeClient.TradeInfo.ToPetInfoList
		TradeClient.SelfInfo.TradeList = TradeClient.TradeInfo.ToTradeList
		TradeClient.OtherInfo.Confirm = TradeClient.TradeInfo.FromConfirm
		TradeClient.OtherInfo.PetInfoList = TradeClient.TradeInfo.FromPetInfoList
		TradeClient.OtherInfo.TradeList = TradeClient.TradeInfo.FromTradeList
	end
end

function TradeClient:OnRejectInvite()
	UIManager:Show("TradeInfo", {
		Success = false,
		Message = Define.Message.TradeRejected,
	})
	
	TradeClient:Clear()
end

function TradeClient:OnAcceptInvite(tradeInfo)
	TradeClient:SetTradeInfo(tradeInfo)
	local uiPage = UIManager:GetCurrentPage()	
	if uiPage.Name ~= "UITrade" then
		UIManager:ShowAndHideOther("Trade")
	end
end

function TradeClient:OnCancelInvite()
	local uiPage = UIManager:GetCurrentPage()
	if uiPage.Name == "UITradeInvite" then
		UIManager:Hide("TradeInvite")
		UIManager:Show("TradeInfo", {
			Success = false,
			Message = Define.Message.TradeCanceld,
		})
	end
	
	TradeClient:Clear()
end

function TradeClient:OnUpdate(tradeInfo)
	TradeClient:SetTradeInfo(tradeInfo)
	local uiPage = UIManager:GetCurrentPage()	
	if uiPage.Name == "UITrade" then
		uiPage.Script:Refresh()
	end
end

function TradeClient:OnPackageFull()
	UIManager:ShowMessage(Define.Message.TradePackageFull)
end

function TradeClient:OnClose()
	local uiPage = UIManager:GetCurrentPage()	
	if uiPage.Name == "UITrade" then
		UIManager:Hide("Trade")
		UIManager:Show("TradeInfo", {
			Success = false,
			Message = Define.Message.TradeClose,
		})
	end
	
	TradeClient:Clear()
end

function TradeClient:OnComplete()
	local uiPage = UIManager:GetCurrentPage()	
	if uiPage.Name == "UITrade" then
		UIManager:Hide("Trade")
		UIManager:Show("TradeInfo", {
			Success = true,
			Message = Define.Message.TradeComplete,
		})
	end
	
	TradeClient:Clear()
end

return TradeClient
