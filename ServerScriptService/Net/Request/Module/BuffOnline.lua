local BuffOnlineHandler = require(game.ServerScriptService.ScriptAlias.BuffOnlineHandler)

local BuffOnline = {}

function BuffOnline:GetProperty(player, param)
	local result = BuffOnlineHandler:GetProperty(player)
	return result
end

return BuffOnline
