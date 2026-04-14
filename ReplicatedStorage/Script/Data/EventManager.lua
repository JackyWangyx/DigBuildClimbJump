local RunService = game:GetService("RunService")

local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local EventManager = {}

EventManager.Define = require(game.ReplicatedStorage.Define).Event

local EventCache = {}

function EventManager:Listen(event, func)
	local eventList = EventManager:GetEventList(event)

	local connection
	local eventInfo = {
		Event = event,
		Func = func,
		Disconnect = function()
			EventManager:Remove(event, func)
			connection = nil
		end,
	}
	
	table.insert(eventList, eventInfo)
	return eventInfo
end

function EventManager:Remove(event, func)
	local eventList = EventManager:GetEventList(event)
	local result = Util:ListRemoveWithCondition(eventList, function(eventInfo)
		return eventInfo.Func == func
	end)
	
	return result
end

function EventManager:Dispatch(event, param)
	local eventList = EventManager:GetEventList(event)
	for _, eventInfo in ipairs(eventList) do
		local eventType = eventInfo.Event
		local func = eventInfo.Func
		local success, message = pcall(func, param)
		
		if not success then
			warn("[Event] ", event, debug.traceback(message, 2))
		end
	end
end

function EventManager:GetAllEventList()
	local list = EventCache
	return list
end

function EventManager:GetEventList(event)
	local eventList = EventCache[event]
	if not eventList then
		eventList = {}
		EventCache[event] = eventList
	end
	
	return eventList
end

----------------------------------------------------------------------------------------
-- Client Only

function EventManager:DispatchToServer(event, param)
	local isClient = RunService:IsClient()
	if not isClient then return end
	local netClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
	netClient:Request("System", "DispatchEvent", { 
		EventName = event,
		EventParam = param
	})
end

----------------------------------------------------------------------------------------
-- Server Only

function EventManager:DispatchToClient(player, event, param)
	local isClient = RunService:IsClient()
	if isClient then return end
	if typeof(player) ~= "Instance" then return end
    if not player:IsDescendantOf(game.Players) then return end
    if player.Parent == nil then return end
	local netServer = require(game.ServerScriptService.ScriptAlias.NetServer)
	netServer:Broadcast(player, "System", "DispatchEvent", { 
		EventName = event,
		EventParam = param
	})
end

function EventManager:DispatchToAllClient(event, param)
	for _, player in pairs(game.Players:GetPlayers()) do
		EventManager:DispatchToClient(player, event, param)
	end
end

return EventManager
