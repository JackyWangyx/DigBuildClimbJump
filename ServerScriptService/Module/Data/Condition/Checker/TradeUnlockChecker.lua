local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local Define = require(game.ReplicatedStorage.Define)

local TradeUnlockChecker = {}

function TradeUnlockChecker:Check(player, requireValue, param)
	local info = NetServer:RequireModule("Rebirth"):GetInfo(player)
	local count = info.ID - 1
	return {
		Success = count >= Define.Game.TradeRequireRebirthLevel,
		CurrentValue = count,
		RequireValue = Define.Game.TradeRequireRebirthLevel,
	}	
end

return TradeUnlockChecker
