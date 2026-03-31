local RunService = game:GetService("RunService")

local UpdatorManager = {}

local IsClient = true
local IsRunning = false

-- 更新缓存
local RenderCache = {}
local HeartbeatCache = {}
local SteppedCache = {}

-- RunService Connections
local RenderConnection = nil
local HeartbeatConnection = nil
local SteppedConnection = nil

------------------------------------------------------------------------------------------
-- 内部工具

local function SortByPriority(cache)
	table.sort(cache, function(a, b)
		return a.Priority < b.Priority
	end)
end

local function RemoveFromCache(cache, updator)
	for i = 1, #cache do
		if cache[i] == updator then
			table.remove(cache, i)
			return
		end
	end
end

local function CreateHandle(cache, updator)
	local handle = {}

	function handle:Enable()
		updator.Enabled = true
	end

	function handle:Disable()
		updator.Enabled = false
	end

	function handle:Disconnect()
		updator.Enabled = false
		RemoveFromCache(cache, updator)
	end

	-- 向后兼容
	function handle:Destroy()
		self:Disconnect()
	end

	return handle
end

-- 安全调用（防止单个系统报错中断整个 Update）
local function SafeCall(updator, dt)
	local ok, err = pcall(updator.Func, dt)

	if not ok then
		updator.Enabled = false
		updator.LastError = err

		warn("[UpdatorManager] Update error, system disabled:", debug.traceback(err, 2))
	end
end

------------------------------------------------------------------------------------------
-- Init / Shutdown

function UpdatorManager:Init()
	if IsRunning then
		return
	end
	
	IsClient = RunService:IsClient()
	IsRunning = true

	if IsClient then
		RenderConnection = RunService:BindToRenderStep("RenderStepLogic", Enum.RenderPriority.Camera.Value - 1, function(dt)
			UpdatorManager:RenderSteppedImpl(dt)
		end)
	end
	
	HeartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		UpdatorManager:HeartbeatImpl(dt)
	end)

	SteppedConnection = RunService.Stepped:Connect(function(_, dt)
		UpdatorManager:SteppedImpl(dt)
	end)
end

-- 🔴 可选：整体关闭 UpdatorManager
function UpdatorManager:Shutdown()
	if not IsRunning then
		return
	end
	IsRunning = false

	if RenderConnection then
		RenderConnection:Disconnect()
		RenderConnection = nil
	end

	if HeartbeatConnection then
		HeartbeatConnection:Disconnect()
		HeartbeatConnection = nil
	end

	if SteppedConnection then
		SteppedConnection:Disconnect()
		SteppedConnection = nil
	end

	table.clear(RenderCache)
	table.clear(HeartbeatCache)
	table.clear(SteppedCache)
end

------------------------------------------------------------------------------------------
-- API

local function Register(cache, func, interval, priority)
	local updator = {
		Func = func,
		Interval = interval or 0,
		Elapsed = 0,
		Priority = priority or 100,
		Enabled = true,

		-- Debug / Error
		LastError = nil,
	}

	cache[#cache + 1] = updator
	SortByPriority(cache)

	return CreateHandle(cache, updator)
end

function UpdatorManager:RenderStepped(func, interval, priority)
	if not IsClient then return end
	self:Init()
	return Register(RenderCache, func, interval, priority)
end

function UpdatorManager:Heartbeat(func, interval, priority)
	self:Init()
	return Register(HeartbeatCache, func, interval, priority)
end

function UpdatorManager:Stepped(func, interval, priority)
	self:Init()
	return Register(SteppedCache, func, interval, priority)
end

------------------------------------------------------------------------------------------
-- Impl（统一执行逻辑，带错误隔离）

local function ExecuteCache(cache, dt)
	for i = 1, #cache do
		local updator = cache[i]
		if updator.Enabled then
			if updator.Interval <= 0 then
				SafeCall(updator, dt)
			else
				updator.Elapsed += dt
				if updator.Elapsed >= updator.Interval then
					updator.Elapsed -= updator.Interval
					SafeCall(updator, dt)
				end
			end
		end
	end
end

function UpdatorManager:RenderSteppedImpl(dt)
	ExecuteCache(RenderCache, dt)
end

function UpdatorManager:HeartbeatImpl(dt)
	ExecuteCache(HeartbeatCache, dt)
end

function UpdatorManager:SteppedImpl(dt)
	ExecuteCache(SteppedCache, dt)
end

------------------------------------------------------------------------------------------
-- Debug / 状态查询

function UpdatorManager:GetStats()
	local status = {}

	local function Collect(cache, name)
		for i = 1, #cache do
			local u = cache[i]
			status[#status + 1] = {
				Type = name,
				Priority = u.Priority,
				Interval = u.Interval,
				Enabled = u.Enabled,
				LastError = u.LastError,
			}
		end
	end

	Collect(RenderCache, "RenderStepped")
	Collect(HeartbeatCache, "Heartbeat")
	Collect(SteppedCache, "Stepped")

	return status
end

------------------------------------------------------------------------------------------

return UpdatorManager
