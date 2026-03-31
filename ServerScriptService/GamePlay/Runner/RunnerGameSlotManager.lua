local Players = game:GetService("Players")

local RunnerGameSlotManager = {}

RunnerGameSlotManager.SlotCount = 0
RunnerGameSlotManager.SlotList = {}
RunnerGameSlotManager.RequestQueue = {}
RunnerGameSlotManager.Processing = false

local RequestType = {
	Enter = "Enter",
	Leave = "Leave",
}

function RunnerGameSlotManager:Init(count, onEnter, onLeave)
	self.SlotCount = count
	self.SlotList = {}
	self.RequestQueue = {}
	self.Processing = false

	for i = 1, count do
		local slotInfo = {
			Index = i,
			Player = nil,
			OnEnter = onEnter,
			OnLeave = onLeave,
		}
		
		table.insert(self.SlotList, slotInfo)
	end

	-- 退出由上层逻辑调用
	--Players.PlayerRemoving:Connect(function(player)
	--	self:Leave(player)
	--end)
end

-- Get Info
function RunnerGameSlotManager:IsPlayerInSlot(player)
	return self:GetSlotByPlayer(player) ~= nil
end

function RunnerGameSlotManager:IsFull()
	return self:GetEmptySlot() == nil
end

function RunnerGameSlotManager:GetEmptySlot()
	for _, slotInfo in ipairs(self.SlotList) do
		if slotInfo.Player == nil then
			return slotInfo
		end
	end
	return nil
end

function RunnerGameSlotManager:GetSlotByIndex(index)
	if index < 1 or index > self.SlotCount then return nil end
	return self.SlotList[index]
end

function RunnerGameSlotManager:GetSlotByPlayer(player)
	for _, slotInfo in ipairs(self.SlotList) do
		if slotInfo.Player == player then
			return slotInfo
		end
	end
	return nil
end

function RunnerGameSlotManager:GetEnableSlotList()
	local enableSlots = {}
	for _, slotInfo in ipairs(self.SlotList) do
		if slotInfo.Player == nil then
			table.insert(enableSlots, slotInfo)
		end
	end
	return enableSlots
end

function RunnerGameSlotManager:GetBusySlotList()
	local enableSlots = {}
	for _, slotInfo in ipairs(self.SlotList) do
		if slotInfo.Player ~= nil then
			table.insert(enableSlots, slotInfo)
		end
	end
	return enableSlots
end

-- Internal

local function EnqueueRequest(self, player, requestType, callback)
	if not player then
		if callback then callback(false, nil) end
		return
	end

	table.insert(self.RequestQueue, {
		Type = requestType,
		Player = player,
		Callbacks = { callback },
	})

	if not self.Processing then
		self.Processing = true
		task.defer(function()
			self:ProcessRequests()
		end)
	end
end

-- Enter / Leave
function RunnerGameSlotManager:Enter(player, callback)
	local existSlot = self:GetSlotByPlayer(player)
	if existSlot then
		if callback then callback(false, existSlot) end
		return
	end
	
	EnqueueRequest(self, player, RequestType.Enter, callback)
end

function RunnerGameSlotManager:Leave(player, callback)
	if not self:IsPlayerInSlot(player) then
		if callback then callback(false, nil) end
		return
	end
	
	EnqueueRequest(self, player, RequestType.Leave, callback)
end

function RunnerGameSlotManager:ProcessRequests()
	while #self.RequestQueue > 0 and self.Processing do
		local request = table.remove(self.RequestQueue, 1)

		if request.Type == RequestType.Enter then
			local emptySlot = self:GetEmptySlot()
			local success = emptySlot ~= nil
			if success then
				emptySlot.Player = request.Player
			end

			for _, cb in ipairs(request.Callbacks) do
				if cb then cb(success, emptySlot) end
			end

			if success and emptySlot.OnEnter then
				emptySlot.OnEnter(request.Player)
			end

		elseif request.Type == RequestType.Leave then
			local slot = self:GetSlotByPlayer(request.Player)
			local success = slot ~= nil
			if success then
				slot.Player = nil
			end

			for _, cb in ipairs(request.Callbacks) do
				if cb then cb(success, slot) end
			end

			if success and slot.OnLeave then
				slot.OnLeave(request.Player)
			end
		end
	end

	self.Processing = false
end

-- Clear
function RunnerGameSlotManager:Clear()
	for _, slotInfo in ipairs(self.SlotList) do
		slotInfo.Player = nil
	end
	
	self.RequestQueue = {}
	self.Processing = false
end

return RunnerGameSlotManager
