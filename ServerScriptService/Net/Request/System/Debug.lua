local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local DebugServer = require(game.ServerScriptService.Debug.DebugServer)

local Debug = {}

function Debug:IsGameOwner(player)
	local isOwner = DebugServer:IsGameOwner(player)
	return isOwner
end

function Debug:GetCommandList(player)
	local result = {}
	if not Debug:IsGameOwner(player) then return result end
	local debugComandFolder = game.ServerScriptService.Debug.Command
	for _, moduleScript in ipairs(debugComandFolder:GetChildren()) do
		local module = require(moduleScript)
		for funcName, func in pairs(module) do
			if typeof(func) ~= "function" then continue end
			local data = {
				Module = moduleScript.Name,
				Action = funcName,
				Color = module.Color,
				Icon = module.Icon
			}
			table.insert(result, data)
		end
	end
	
	return result
end

function Debug:ExecuteCommand(player, param)
	local module = param.Module
	local action = param.Action
	local param = param.Param
	DebugServer:ExecuteCommand(player, module, action, param)
	return true
end

return Debug
