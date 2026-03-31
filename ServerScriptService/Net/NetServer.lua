local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local NetDefine = require(game.ReplicatedStorage.ScriptAlias.NetDefine)
local NetEvent = require(game.ReplicatedStorage.ScriptAlias.NetEvent)
local DataPackDispatcher = require(game.ReplicatedStorage.ScriptAlias.DataPackDispatcher)
local DataPackProcessor = require(game.ReplicatedStorage.ScriptAlias.DataPackProcessor)

local NetServer = {}

local BroadcastBuffer = {}
local BroadcastAllBuffer = {}

local ConnectedPlayerList = {}

function NetServer:Init()
	NetEvent:Init()
	DataPackDispatcher:Init()
	DataPackProcessor:Init()
	
	ConnectedPlayerList = {}
	
	NetEvent.Connect.OnServerEvent:Connect(function(player)
		NetServer:OnPlayerConnect(player)
	end)
	
	game.Players.PlayerRemoving:Connect(function(player)
		NetServer:OnPlayerDisconnect(player)
	end)
	
	NetEvent.Request.OnServerInvoke = function(player, data)	
		local result = NetServer:OnRequest(player, data)
		return result
	end
	
	NetEvent.RequestQueue.OnServerInvoke = function(player, data)
		local result = NetServer:OnRequestQueue(player, data)
		return result
	end
	
	UpdatorManager:Heartbeat(function(deltaTime)
		NetServer:Update(deltaTime)
	end)
end

-- Player

function NetServer:OnPlayerConnect(player)
	ConnectedPlayerList[player] = player
end

function NetServer:OnPlayerDisconnect(player)
	ConnectedPlayerList[player] = nil
end

function NetServer:IsPlayerConnected(player)
	return ConnectedPlayerList[player] ~= nil
end

local function IsListEmpty(target)
	if target == nil then return true end
	if next(target) == nil then return true end
	return false
end

-- Update

local UpdateTimer = 0
local UpdateInterval = 0.05

function NetServer:Update(deltaTime)
	if not NetDefine.MergeBroadcast then
		return
	end
	
	UpdateTimer += deltaTime
	if UpdateTimer < UpdateInterval then
		return
	end
	
	UpdateTimer -= UpdateInterval
	
	if not IsListEmpty(BroadcastBuffer) then
		for player, requestList in pairs(BroadcastBuffer) do
			if not player then continue end
			if not NetServer:IsPlayerConnected(player) then continue end
			
			local broadcastData = DataPackProcessor:Send(nil, requestList)
			NetEvent.Broadcast:FireClient(player, broadcastData)
		end
		BroadcastBuffer = {}
	end
	
	if #BroadcastAllBuffer > 0 then
		local requestList = BroadcastAllBuffer
		local broadcastData = DataPackProcessor:Send(nil, requestList)
		for player, _ in pairs(ConnectedPlayerList) do
			NetEvent.Broadcast:FireClient(player, broadcastData)
		end
		BroadcastAllBuffer = {}
	end
end

-- On Request

function NetServer:OnRequest(player, data)
	local request = DataPackProcessor:Receive(player, data)
	local module = request.Module
	local action = request.Action
	local param = request.Param
	local result = DataPackDispatcher:Dispatch(NetDefine.RequestType.Request, player, module, action, param)
	result = DataPackProcessor:Send(nil, result)
	return result
end

function NetServer:OnRequestQueue(player, data)
	local requestList = DataPackProcessor:Receive(player, data)
	local result = {}
	for _, request in pairs(requestList) do
		local requestResult = NetServer:OnRequest(player, request)
		table.insert(result, requestResult)
	end
	result = DataPackProcessor:Send(nil, result)
	return result
end

-- Broadcast

function NetServer:GetBroadcastBuffer()
	return BroadcastBuffer
end

function NetServer:Broadcast(player, module, action, param)
	if not player then return end
	if not NetServer:IsPlayerConnected(player) then return end
	
	local request = {
		Module = module,
		Action = action,
		Param = param
	}
	
	if NetDefine.MergeBroadcast then
		local requestList = BroadcastBuffer[player]
		if not requestList then
			requestList = {}
			BroadcastBuffer[player] = requestList
		end
		table.insert(requestList, request)
	else
		request = DataPackProcessor:Send(nil, request)
		NetEvent.Broadcast:FireClient(player, request)
	end
end

function NetServer:BroadcastAll(module, action, param)
	local request = {
		Module = module,
		Action = action,
		Param = param
	}
	
	if NetDefine.MergeBroadcast then
		table.insert(BroadcastAllBuffer, request)
	else
		request = DataPackProcessor:Send(nil, request)
		for player, _ in pairs(ConnectedPlayerList) do
			NetEvent.Broadcast:FireClient(player, request)
		end
	end
end

-- Module

function NetServer:RequireModule(moduleName)
	return DataPackDispatcher:RequireModule(moduleName)
end

return NetServer