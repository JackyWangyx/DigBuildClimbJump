local SignatureUtil = require(game.ReplicatedStorage.ScriptAlias.SignatureUtil)
local NetEvent = require(game.ReplicatedStorage.ScriptAlias.NetEvent)

local SignatureServer = {}
local PlayerKeyCache = {}

local DefaultKey = SignatureUtil:GenerateKey()

function SignatureServer:Init()
	SignatureUtil:Init()
	
	NetEvent.Signature.OnServerInvoke = function(player, request)
		if request == "GetInitData" then
			local data = {
				Key = SignatureServer:GetKey(player),
				Timestamp = os.time()
			}
			
			return data
		else
			return nil
		end
	end
	
	for _, player in pairs(game.Players:GetPlayers()) do
		SignatureServer:OnPlayerAdded(player)
	end
	
	game.Players.PlayerAdded:Connect(function(player)
		SignatureServer:OnPlayerAdded(player)
	end)
	
	game.Players.PlayerRemoving:Connect(function(player)
		SignatureServer:OnPlayerRemoved(player)
	end)
end

function SignatureServer:GetKey(player)
	if not player then return DefaultKey end
	return PlayerKeyCache[player] 
end

function SignatureServer:OnPlayerAdded(player)
	local key = SignatureUtil:GenerateKey()
	PlayerKeyCache[player] = key
end

function SignatureServer:OnPlayerRemoved(player)
	PlayerKeyCache[player] = nil
end

return SignatureServer
