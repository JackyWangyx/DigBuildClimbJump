local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local NetSever = require(game.ServerScriptService.ScriptAlias.NetServer)
local RebirthRequest = require(game.ServerScriptService.ScriptAlias.Rebirth)
local IAPRequest = require(game.ServerScriptService.ScriptAlias.IAP)

local Define = require(game.ReplicatedStorage.Define)

local AutoRebirthHandler = {}

local PlayerCache = {}

function AutoRebirthHandler:Init()
	PlayerManager:HandlePlayerAddRemove(function(player)
		AutoRebirthHandler:AddPlayer(player)
	end, function(player)
		PlayerCache[player.UserId] = nil
	end)

	UpdatorManager:Heartbeat(function(deltaTime)
		AutoRebirthHandler:Update(deltaTime)
	end, 2)
end

function AutoRebirthHandler:AddPlayer(player)
	if RebirthRequest:GetAuto(player) then
		PlayerCache[player.UserId] = player
	else
		PlayerCache[player.UserId] = nil
	end	
end

function AutoRebirthHandler:RemovePlayer(player)
	PlayerCache[player.UserId] = nil
end

function AutoRebirthHandler:Update(deltaTime)
	for playerID, player in pairs(PlayerCache) do
		local checkCanRebirth = RebirthRequest:CheckCanRebirth(player)
		if checkCanRebirth then
			RebirthRequest:RebirthAuto(player)
			NetSever:Broadcast(player, "System", "ShowMessage", { Message = Define.Message.AutoRebirth })
		end
	end
end

return AutoRebirthHandler
