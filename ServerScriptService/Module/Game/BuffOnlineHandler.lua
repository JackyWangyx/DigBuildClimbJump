local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local Define = require(game.ReplicatedStorage.Define)

local BuffOnlineHandler = {}

local PlayerDic = {}

function BuffOnlineHandler:Init()
	PlayerDic = {}
	PlayerManager:HandlePlayerAddRemove(function(player)
		BuffOnlineHandler:OnPlayerEnter(player)
	end, function(player)
		BuffOnlineHandler:OnPlayerLeave(player)
	end)
	
	UpdatorManager:Heartbeat(function(deltaTime)
		BuffOnlineHandler:Update(deltaTime)
	end)
end

function BuffOnlineHandler:OnPlayerEnter(player)
	BuffOnlineHandler:GetProperty(player)
end

function BuffOnlineHandler:OnPlayerLeave(player)
	PlayerDic[player] = nil
end

function BuffOnlineHandler:GetProperty(player)
	local result = PlayerDic[player]
	if not result then
		result = {
			CountDown = Define.Game.BuffOnlineInterval,
			Count = 0,
			GetPowerFactor3 = 0,
		}
		
		PlayerDic[player] = result
	end
	
	return result
end

local Timer = 0

function BuffOnlineHandler:Update(deltaTime)
	Timer += deltaTime
	if Timer >= 1 then
		Timer -= 1
	else
		return
	end
	
	for player, info in pairs(PlayerDic) do
		info.CountDown -= 1
		if info.CountDown <= 0 then
			info.CountDown = Define.Game.BuffOnlineInterval
			info.Count += 1
			info.GetPowerFactor3 = info.Count * Define.Game.BuffOnlineValue
			EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
		end	
	end
end

return BuffOnlineHandler
