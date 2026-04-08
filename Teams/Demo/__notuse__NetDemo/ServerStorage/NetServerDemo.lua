local NetServer = require(game.ServerStorage.Net.NetServer)

NetServerDemo = {}

-- Call NetServer:Init in ServerStorage
function NetServerDemo:GameStart()
	NetServer:Init()
end

-- Boradcast to one player
function NetServerDemo:BroadcastTest1()
	local player = game.Players:GetPlayers()[1]
	NetServer:Broadcast("ClientBroadcastModuleDemo", "OnBroadcast", { Message = "Broadcast to client message"})
end

-- Broadcast to all player
function NetServerDemo:BroadcastTest2()
	NetServer:BroadcastAll("ClientBroadcastModuleDemo", "OnBroadcast", { Message = "Broadcast to client message"})
end

return NetServerDemo