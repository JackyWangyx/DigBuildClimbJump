local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local PlayerCache = require(game.ServerScriptService.ScriptAlias.PlayerCache)

local PlayerStatus = {}

PlayerStatus.Define = require(game.ReplicatedStorage.Define).PlayerStatus

function PlayerStatus:Init()
	PlayerManager:HandlePlayerAddRemove(function(player)
		PlayerStatus:SetDefaultStatus(player)
	end, function(player)
		
	end)
end

function PlayerStatus:GetStatusList()
	local result = {}
	for _, player in ipairs(game.Players:GetPlayers()) do
		local info = {
			PlayerID = player.UserId,
			Status = PlayerStatus:GetStatus(player)
		}
		
		table.insert(result, info)
	end
	
	return result
end

function PlayerStatus:SetStatus(player, status)
	local currentStatus = PlayerStatus:GetStatus(player)
	if currentStatus ~= nil and currentStatus == status then
		return
	end
	
	PlayerCache:SetValue(player, "Status", status)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerStatus, {
		Player = player,
		Status = status,
	})
	
	EventManager:DispatchToClient(player, EventManager.Define.RefreshPlayerStatus, status)
end

function PlayerStatus:GetStatus(player)
	local result = PlayerCache:GetValue(player, "Status")
	return result
end

function PlayerStatus:SetDefaultStatus(player)
	PlayerStatus:SetStatus(player, PlayerStatus.Define.Idle)
end

return PlayerStatus
