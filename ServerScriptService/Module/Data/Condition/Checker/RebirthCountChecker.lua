local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local RebirthCountChecker = {}

function RebirthCountChecker:Check(player, requireValue, param)
	local info = NetServer:RequireModule("Rebirth"):GetInfo(player)
	local count = info.ID - 1
	return {
		Success = count >= requireValue,
		CurrentValue = count,
		RequireValue = requireValue,
	}	
end

return RebirthCountChecker
