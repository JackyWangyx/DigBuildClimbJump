local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConditionUtil = require(game.ReplicatedStorage.ScriptAlias.ConditionUtil)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local Define = require(game.ReplicatedStorage.Define)


local TradeInfoTemplate = {
	ID = 123,
	StartTime = 123,
	FromPlayerID = 123,
	FromConfirm = false,
	FromTradeList = {

	},
	ToPlayerID = 123,
	ToConfirm = false,
	ToTradeList = {

	}
}

local TradeServer = {}

local TradeList = {}

function LoadInfo(player)
	local saveInfo = PlayerPrefs:GetModule(player, "Trade")
	return saveInfo
end

function TradeServer:Init()
	PlayerManager:HandlePlayerAddRemove(function(player)
		
	end, function(player)
		TradeServer:OnPlayerRemove(player)
	end)
end

function TradeServer:OnPlayerRemove(player)
	local trade = TradeServer:GetTrade(player)
	if not trade then return end
	
	local fromPlayer = PlayerManager:GetPlayerById(trade.FromPlayerID)
	local toPlayer = PlayerManager:GetPlayerById(trade.ToPlayerID)
	
	EventManager:DispatchToClient(fromPlayer, EventManager.Define.TradeClose)
	EventManager:DispatchToClient(toPlayer, EventManager.Define.TradeClose)
	
	Util:ListRemove(TradeList, trade)
end

function TradeServer:GetPlayerList(player)
	local result = {}
	local players = game.Players:GetPlayers()
	for _, tempPlayer in pairs(players) do
		if not Define.Test.EnableSelfTrade and tempPlayer.UserId == player.UserId then continue end
		
		local existTrade = TradeServer:GetTrade(player)
		if existTrade then continue end
		
		local playerInfo = {
			UserID = tempPlayer.UserId,
			Name = tempPlayer.Name,
			State = TradeServer:GetPlayerState(tempPlayer),
			DisplayName = tempPlayer.DisplayName,
		}
		
		table.insert(result, playerInfo)
	end
	
	return result
end

function TradeServer:GetPlayerState(player)
	local saveInfo = LoadInfo(player)
	if saveInfo.Enable == nil then saveInfo.Enable = true end
	if not saveInfo.Enable then
		return Define.TradePlayerState.Disable
	end
	
	local tradeUnlock = ConditionUtil:Check(player, ConditionUtil.Define.TradeUnlock)
	if not tradeUnlock then
		return Define.TradePlayerState.Disable
	end
	
	local existTrade = TradeServer:GetTrade(player)
	if not existTrade then return Define.TradePlayerState.Idle end
	
	if existTrade.State == Define.TradeState.Prepare then
		return Define.TradePlayerState.Wait 
	else
		return Define.TradePlayerState.Busy
	end
end

function TradeServer:GetEnable(player)
	local saveInfo = LoadInfo(player)
	if saveInfo.Enable == nil then saveInfo.Enable = true end
	return saveInfo.Enable
end

function TradeServer:Switch(player)
	local saveInfo = LoadInfo(player)
	if saveInfo.Enable == nil then saveInfo.Enable = true end
	if saveInfo.Enable then
		saveInfo.Enable = false
	else
		saveInfo.Enable = true
	end
end

function TradeServer:GetTrade(player)
	if not player then return nil end
	for _, trade in pairs(TradeList) do
		local formPlayer = PlayerManager:GetPlayerById(trade.FromPlayerID)
		local toPlayer = PlayerManager:GetPlayerById(trade.ToPlayerID)
		if formPlayer and formPlayer.UserId == player.UserId then
			return trade
		end
		if toPlayer and toPlayer.UserId == player.UserId then
			return trade
		end
	end
	
	return nil
end

-- Invite

function TradeServer:Invite(fromPlayer, toPlayer)
	local existTrande = TradeServer:GetTrade(fromPlayer)
	if existTrande then return nil end
	if not fromPlayer then return nil end
	if not toPlayer then return nil end
	local trade = {
		StartTime = tick(),
		State = Define.TradeState.Prepare,
		ConfirmTime = 0,
		FromPlayerID = fromPlayer.UserId,
		FromConfirm = false,
		FromTradeList = {},
		FromPetInfoList = {},
		ToPlayerID = toPlayer.UserId,
		ToConfirm = false,
		ToTradeList = {},
		ToPetInfoList = {},
	}
	
	trade.FromPetInfoList = NetServer:RequireModule("Pet"):GetPackageList(fromPlayer)
	trade.ToPetInfoList = NetServer:RequireModule("Pet"):GetPackageList(toPlayer)
	
	local toPlayer = PlayerManager:GetPlayerById(trade.ToPlayerID)
	EventManager:DispatchToClient(toPlayer, Define.Event.TradeInvite, trade)
	
	table.insert(TradeList, trade)
	
	return trade
end

function TradeServer:CancelInvite(player)
	local trade = TradeServer:GetTrade(player)
	if not trade then return end
	local fromPlayer = PlayerManager:GetPlayerById(trade.FromPlayerID)
	local toPlayer = PlayerManager:GetPlayerById(trade.ToPlayerID)
	EventManager:DispatchToClient(fromPlayer, EventManager.Define.TradeCancelInvite)
	EventManager:DispatchToClient(toPlayer, EventManager.Define.TradeCancelInvite)
	Util:ListRemove(TradeList, trade)
end

function TradeServer:RejectInvite(player)
	if not player then return end
	local trade = TradeServer:GetTrade(player)
	if trade == nil then return end	
	
	local fromPlayer = PlayerManager:GetPlayerById(trade.FromPlayerID)
	EventManager:DispatchToClient(fromPlayer, Define.Event.TradeRejectInvite, trade)
	Util:ListRemove(TradeList, trade)
end

function TradeServer:AcceptInvite(player)
	if not player then return end
	local trade = TradeServer:GetTrade(player)
	if trade == nil then return end	
	
	trade.State = Define.TradeState.Trading
	local fromPlayer = PlayerManager:GetPlayerById(trade.FromPlayerID)
	local toPlayer = PlayerManager:GetPlayerById(trade.ToPlayerID)
	EventManager:DispatchToClient(fromPlayer, Define.Event.TradeAcceptInvite, trade)
	EventManager:DispatchToClient(toPlayer, Define.Event.TradeAcceptInvite, trade)
end

function TradeServer:UpdateConfirm(player, confirm)
	if not player then return end
	local trade = TradeServer:GetTrade(player)
	if trade == nil then return end	
	
	local fromPlayer = PlayerManager:GetPlayerById(trade.FromPlayerID)
	local toPlayer = PlayerManager:GetPlayerById(trade.ToPlayerID)
	
	local checkPackage = TradeServer:CheckPackage(player)
	if not checkPackage then
		EventManager:DispatchToClient(fromPlayer, Define.Event.TradePackageFull)
		EventManager:DispatchToClient(toPlayer, Define.Event.TradePackageFull)
		return
	end
	
	if player.UserId == trade.FromPlayerID then
		trade.FromConfirm = confirm
	end
	
	if player.UserId == trade.ToPlayerID then
		trade.ToConfirm = confirm
	end
	
	if trade.FromConfirm and trade.ToConfirm then
		trade.ConfirmTime = tick()
	else
		trade.ConfirmTime = 0
	end
	
	EventManager:DispatchToClient(fromPlayer, Define.Event.TradeUpdate, trade)
	EventManager:DispatchToClient(toPlayer, Define.Event.TradeUpdate, trade)
end

function TradeServer:CheckPackage(player)
	local trade = TradeServer:GetTrade(player)
	if trade == nil then return true end
	
	local fromPlayer = PlayerManager:GetPlayerById(trade.FromPlayerID)
	local fromCheck = NetServer:RequireModule("Pet"):CheckPackage(fromPlayer, { Value = #trade.ToTradeList })
	local toPlayer = PlayerManager:GetPlayerById(trade.ToPlayerID)
	local toCheck = NetServer:RequireModule("Pet"):CheckPackage(toPlayer, { Value = #trade.FromTradeList })
	
	return fromCheck and toCheck
end

function TradeServer:UpdateSelectList(player, selectList)
	if not player then return end
	local trade = TradeServer:GetTrade(player)
	if trade == nil then return end	

	if player.UserId == trade.FromPlayerID then
		trade.FromTradeList = selectList
	end

	if player.UserId == trade.ToPlayerID then
		trade.ToTradeList = selectList
	end

	if trade.FromConfirm and trade.ToConfirm then
		trade.ConfirmTime = tick()
	else
		trade.ConfirmTime = 0
	end

	local fromPlayer = PlayerManager:GetPlayerById(trade.FromPlayerID)
	local toPlayer = PlayerManager:GetPlayerById(trade.ToPlayerID)
	EventManager:DispatchToClient(fromPlayer, Define.Event.TradeUpdate, trade)
	EventManager:DispatchToClient(toPlayer, Define.Event.TradeUpdate, trade)
end

function TradeServer:Close(player)
	if not player then return end
	local trade = TradeServer:GetTrade(player)
	if trade == nil then return end	

	local fromPlayer = PlayerManager:GetPlayerById(trade.FromPlayerID)
	local toPlayer = PlayerManager:GetPlayerById(trade.ToPlayerID)
	EventManager:DispatchToClient(fromPlayer, Define.Event.TradeClose, trade)
	EventManager:DispatchToClient(toPlayer, Define.Event.TradeClose, trade)
	
	Util:ListRemove(TradeList, trade)
end

function TradeServer:Complete(player)
	if not player then return end
	local trade = TradeServer:GetTrade(player)
	if trade == nil then return end	

	local fromPlayer = PlayerManager:GetPlayerById(trade.FromPlayerID)
	local toPlayer = PlayerManager:GetPlayerById(trade.ToPlayerID)

	local petRequest = NetServer:RequireModule("Pet")
	-- From
	for _, info in ipairs(trade.FromTradeList) do
		petRequest:Delete(fromPlayer, { InstanceID = info.InstanceID })
		petRequest:Add(toPlayer, { ID = info.ID, UpgradeLevel = info.UpgradeLevel})
	end
	
	local list1 = petRequest:GetPackageList(player)
	--print(list1, #list1)

	-- To
	for _, info in ipairs(trade.ToTradeList) do
		petRequest:Delete(toPlayer, { InstanceID = info.InstanceID })
		petRequest:Add(fromPlayer, { ID = info.ID, UpgradeLevel = info.UpgradeLevel})
	end
	
	local list2 = petRequest:GetPackageList(player)
	--print(list2, #list2)

	EventManager:DispatchToClient(fromPlayer, Define.Event.TradeComplete, trade)
	EventManager:DispatchToClient(toPlayer, Define.Event.TradeComplete, trade)
	
	Util:ListRemove(TradeList, trade)
end

return TradeServer
