local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local ConditionUtil = require(game.ReplicatedStorage.ScriptAlias.ConditionUtil)

local TradeServer = require(game.ServerScriptService.ScriptAlias.TradeServer)

local Trade = {}

function Trade:GetPlayerList(player)
	local result = TradeServer:GetPlayerList(player)
	return result
end

-- Switch

function Trade:GetEnable(player)
	local result = TradeServer:GetEnable(player)
	return result
end

function Trade:Switch(player)
	local result = TradeServer:Switch(player)
	return result
end

-- Invite

function Trade:Invite(player, param)
	local targetPlayerID = param.TargetPlayerID
	local targetPlayer = PlayerManager:GetPlayerById(targetPlayerID)
	local trade = TradeServer:Invite(player, targetPlayer)
	return trade
end

function Trade:CancelInvite(player)
	TradeServer:CancelInvite(player)
	return true
end

function Trade:RejectInvite(player)
	TradeServer:RejectInvite(player)
	return true
end

function Trade:AcceptInvite(player)
	TradeServer:AcceptInvite(player)
	return true
end

function Trade:UpdateSelectList(player, param)
	local selectList = param.SelectList
	TradeServer:UpdateSelectList(player, selectList)
	return true
end

function Trade:UpdateConfirm(player, param)
	local confirm = param.Confirm
	TradeServer:UpdateConfirm(player, confirm)
	return true
end

function Trade:Close(player)
	TradeServer:Close(player)
	return true
end

function Trade:Complete(player)
	TradeServer:Complete(player)
	return true
end

return Trade
