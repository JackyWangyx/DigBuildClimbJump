local NetClient = require(game.ReplicatedStorage.Script.Net.NetClient)

NetClientDemo = {}

-- Call NetClient:Init in StarterPlayer/StarterPlayerScripts
function NetClientDemo:GameStart()
	NetClient:Init()
end

-- Call Net Request in any client script after inited
-- Request without return value async
function NetClientDemo:RequestTest1()
	NetClient:Request("ServerRequestModuleDemo", "OnRequest", { Message = "Send message to server"})
end

-- Request with return value async
function NetClientDemo:RequestTest2()
	NetClient:Request("ServerRequestModuleDemo", "OnRequest", { Message = "Send message to server"}, function(result)
		print(result)
	end)
end

-- Request without param and return value async
function NetClientDemo:RequestTest3()
	NetClient:Request("ServerRequestModuleDemo", "OnRequest")
end

-- Request and wait for return value
function NetClientDemo:RequestTest4()
	local result = NetClient:RequestWait("ServerRequestModuleDemo", "OnRequest")
	print(result)
end

-- Request many action in once
function NetClientDemo:RequestTest5()
	NetClient:RequestQueue({
		{
			Module = "ServerRequestModuleDemo",
			Action = "OnRequest", 
			Param = { 
				Message = "Message1"
			}
		},
		{
			Module = "ServerRequestModuleDemo",
			Action = "OnRequest", 
			Param = { 
				Message = "Message2"
			}
		}
	}, function(result)
		local result1 = result[1]
		print(result1)
		
		local result2 = result[2]
		print(result2)
	end)
end

return NetClientDemo