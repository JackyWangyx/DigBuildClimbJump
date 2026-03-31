-- ThrottleScheduler.lua
local RunService = game:GetService("RunService")

local TaskThrottleScheduler = {}
TaskThrottleScheduler.__index = TaskThrottleScheduler

function TaskThrottleScheduler.new(maxPerMinute, minInterval, retryCount, retryDelay)
	local self = setmetatable({}, TaskThrottleScheduler)
	self.MaxPerMinute = maxPerMinute or 60
	self.MinInterval = minInterval or 0
	self.RetryCount = retryCount or 3
	self.RetryDelay = retryDelay or 2
	self.Queue = {} 
	self.Tokens = maxPerMinute
	self.LastRefill = tick()
	self.RefillInterval = 60 / maxPerMinute
	self.IsRunning = false
	self.LastTaskTime = 0
	return self
end

function TaskThrottleScheduler:GetCount()
	local count = 0
	for _, tastItem in pairs(self.Queue) do
		count += 1
	end
	return count
end

-- 原有添加任务接口
function TaskThrottleScheduler:AddTask(key, taskFunc, priority, timeout)
	local taskItem = {
		Func = taskFunc,
		Retries = self.RetryCount,
		Priority = priority or 0,
		Timestamp = tick(),
		Timeout = timeout or 0,
		Key = key
	}
	table.insert(self.Queue, taskItem)

	table.sort(self.Queue, function(a, b)
		if a.Priority ~= b.Priority then
			return a.Priority > b.Priority
		else
			return a.Timestamp < b.Timestamp
		end
	end)

	if not self.IsRunning then
		self:Start()
	end
end

-- 覆盖添加任务接口，如果队列中已存在相同 Key 的任务，则替换
function TaskThrottleScheduler:AddOrReplaceTask(key, taskFunc, priority, timeout)
	if not key then
		-- 没有 key 就退化为普通添加
		self:AddTask(nil, taskFunc, priority, timeout)
		return
	end

	local replaced = false
	for i, taskItem in ipairs(self.Queue) do
		if taskItem.Key == key then
			self.Queue[i] = {
				Func = taskFunc,
				Retries = self.RetryCount,
				Priority = priority or 0,
				Timestamp = tick(),
				Timeout = timeout or 0,
				Key = key
			}
			replaced = true
			break
		end
	end

	if not replaced then
		self:AddTask(key, taskFunc, priority, timeout)
	end

	table.sort(self.Queue, function(a, b)
		if a.Priority ~= b.Priority then
			return a.Priority > b.Priority
		else
			return a.Timestamp < b.Timestamp
		end
	end)
end

function TaskThrottleScheduler:Cancel(key)
	for i = #self.Queue, 1, -1 do
		if self.Queue[i].Key == key then
			table.remove(self.Queue, i)
		end
	end
end

function TaskThrottleScheduler:Find(key)
	for _, taskItem in ipairs(self.Queue) do
		if taskItem.Key == key then
			return taskItem
		end
	end
	return nil
end

function TaskThrottleScheduler:FindAll(key)
	local result = {}
	for _, taskItem in ipairs(self.Queue) do
		if taskItem.Key == key then
			table.insert(result, taskItem)
		end
	end
	return result
end

function TaskThrottleScheduler:Start()
	self.IsRunning = true
	spawn(function()
		while #self.Queue > 0 do
			local now = tick()
			local delta = now - self.LastRefill
			local refillTokens = math.floor(delta / self.RefillInterval)
			if refillTokens > 0 then
				self.Tokens = math.min(self.Tokens + refillTokens, self.MaxPerMinute)
				self.LastRefill = self.LastRefill + refillTokens * self.RefillInterval
			end

			local waitTime = 0
			if self.Tokens <= 0 then
				waitTime = self.RefillInterval - (tick() - self.LastRefill)
			elseif now - self.LastTaskTime < self.MinInterval then
				waitTime = self.MinInterval - (now - self.LastTaskTime)
			end

			if waitTime > 0 then
				task.wait(waitTime)
			else
				local taskItem = table.remove(self.Queue, 1)
				self.Tokens = self.Tokens - 1
				self.LastTaskTime = tick()

				spawn(function()
					local finished = false
					local success, err

					spawn(function()
						success, err = pcall(taskItem.Func)
						finished = true
					end)

					local startTime = tick()
					while not finished do
						if taskItem.Timeout > 0 and tick() - startTime > taskItem.Timeout then
							warn("[Task] Task timed out : ", taskItem.Key)
							success, err = false, "timeout"
							break
						end
						task.wait(0.05)
					end

					if not success or err == false then
						taskItem.Retries = taskItem.Retries - 1
						if taskItem.Retries > 0 then
							task.wait(self.RetryDelay)
							self:AddTask(taskItem.Func, taskItem.Priority, taskItem.Timeout, taskItem.Key)
						else
							warn("[Task] Task failed after retries:", taskItem.Key, debug.traceback(err, 2))
						end
					end
				end)
			end

			RunService.Heartbeat:Wait()
		end
		self.IsRunning = false
	end)
end

return TaskThrottleScheduler
