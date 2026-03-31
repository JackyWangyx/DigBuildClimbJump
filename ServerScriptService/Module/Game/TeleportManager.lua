local TeleportService = game:GetService("TeleportService")

local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local Define = require(game.ReplicatedStorage.Define)

local TeleportManager = {}

local PlayerCache = {}

game.Players.PlayerRemoving:Connect(function(player)
	PlayerCache[player.UserId] = nil
end)

TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
	--if PlayerCache[player.UserId] then
	--	PlayerCache[player.UserId] = nil
	--end
end)

function TeleportManager:Teleport(player, placeId)
	if not player or not player:IsDescendantOf(game.Players) then
		return {
			Success = false,
			Message = Define.Message.TeleportFail
		}
	end
	if PlayerCache[player.UserId] then
		return {
			Success = false,
			Message = Define.Message.Teleporting
		}
	end

	PlayerCache[player.UserId] = true
	local success, err = pcall(function()
		TeleportService:TeleportAsync(placeId, { player })
	end)

	if not success then
		PlayerCache[player.UserId] = nil
		warn(("[Teleport] Teleport Fail:"), placeId, debug.traceback(err, 2))
		return {
			Success = false,
			Message = Define.Message.TeleportFail
		}
	end

	PlayerCache[player.UserId] = nil
	
	return {
		Success = true,
		Message = ""
	}
end

function TeleportManager:IsTeleporting(player)
	return PlayerCache[player.UserId] ~= nil
end

return TeleportManager
