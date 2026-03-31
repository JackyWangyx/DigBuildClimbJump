local NetDefine = require(script.Parent.NetDefine)
local NetEvent = require(script.Parent.NetEvent)
local DataPackDispatcher = require(script.Parent.DataPackDispatcher)
local DataPackProcessor = require(script.Parent.DataPackProcessor)

local NetClient = {}

function NetClient:Init()
	NetEvent:Init()
	DataPackDispatcher:Init()
	DataPackProcessor:Init()
	
	NetEvent.Broadcast.OnClientEvent:Connect(function(data)
		NetClient:OnBroadcast(data)
	end)
	
	NetEvent.Connect:FireServer()
end

function NetClient:Request(module, action, param, callback)
	if param and not callback and typeof(param) == "function"  then
		callback = param
		param = nil
	end
	
	local request = {
		Module = module,
		Action = action,
		Param = param
	}

	task.spawn(function()
		request = DataPackProcessor:Send(request)
		local result = NetEvent.Request:InvokeServer(request)
		if callback then
			result = DataPackProcessor:Receive(result)
			callback(result)
		end
	end)
end

function NetClient:RequestWait(module, action, param)
	local result = nil
	local request = {
		Module = module,
		Action = action,
		Param = param
	}

	request = DataPackProcessor:Send(request)
	local result = NetEvent.Request:InvokeServer(request)
	result = DataPackProcessor:Receive(result)
	return result
end

function NetClient:RequestQueue(requestList, callback)
	requestList = DataPackProcessor:Send(requestList)
	local result = NetEvent.RequestQueue:InvokeServer(requestList)
	if callback then
		result = DataPackProcessor:Receive(result)
		callback(result)
	end
end

function NetClient:OnBroadcast(dataPack)
	local player = game.Players.LocalPlayer
	dataPack = DataPackProcessor:Receive(dataPack)
	
	if NetDefine.MergeBroadcast then
		local requestList = dataPack
		for _, request in pairs(requestList) do
			local module = request.Module
			local action = request.Action
			local param = request.Param
			DataPackDispatcher:Dispatch(NetDefine.RequestType.Broadcast, player, module, action, param)
		end
	else
		local request = dataPack
		local module = request.Module
		local action = request.Action
		local param = request.Param
		DataPackDispatcher:Dispatch(NetDefine.RequestType.Broadcast, player, module, action, param)
	end
end

function NetClient:RequireModule(moduleName)
	return DataPackDispatcher:RequireModule(moduleName)
end

return NetClient