local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)

local TaskManager = {}

TaskManager.MaxTasksPerFrame = 200

local TaskQueue = {}

local isInit = false
local isRunning = false

function TaskManager:AddTask(taskFn)
	if typeof(taskFn) ~= "function" then return end
	table.insert(TaskQueue, taskFn)
	if not isRunning then
		isRunning = true
	end
	
	if not isInit then
		isInit = true
		Start()
	end
end

function TaskManager:ClearAll()
	table.clear(TaskQueue)
end

function Start()
	UpdatorManager:Heartbeat(function()
		if isRunning then
			local count = 0
			while count < TaskManager.MaxTasksPerFrame and #TaskQueue > 0 do
				local taskFn = table.remove(TaskQueue, 1)
				if taskFn then
					--task.spawn(function()
						taskFn()
					--end)
				end
				count += 1
			end
		end
		
		if #TaskQueue == 0 then
			isRunning = false
		end
	end)
end

return TaskManager
