local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)

local Record = {}

function Record:AddValue(player, param)
	local key = param.Key
	local value = param.Value
	PlayerRecord:AddValue(player, key, value)
	return true
end

function Record:GetValue(player, param)
	local key = param.Key
	local value = PlayerRecord:GetValue(player, key)
	return value
end

return Record
