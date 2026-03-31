local TweenService = game:GetService("TweenService")

local TweenServiceManager = {}
TweenServiceManager.__index = TweenServiceManager

-- 预设缓动配置
local defaultEasing = {
	Style = Enum.EasingStyle.Quad,
	Direction = Enum.EasingDirection.Out,
	Time = 1,
	DelayTime = 0,
	Reverses = false,
	RepeatCount = 0
}

function TweenServiceManager.New(target, config)
	config = config or {}

	local self = setmetatable({
		_target = target,
		_from = nil,
		_tweenInfo = TweenInfo.new(
			config.Time or defaultEasing.Time,
			config.Style or defaultEasing.Style,
			config.Direction or defaultEasing.Direction,
			config.RepeatCount or defaultEasing.RepeatCount,
			config.Reverses or defaultEasing.Reverses,
			config.DelayTime or defaultEasing.DelayTime
		),
		_properties = {},
		_callbacks = {
			OnStart = {},
			OnUpdate = {},
			OnComplete = {}
		},
		_tweenInstance = nil,
		_isPlaying = false
	}, TweenServiceManager)

	return self
end

function TweenServiceManager:From(func)
	self._from = func
	return self
end

-- 链式方法 --
function TweenServiceManager:To(properties)
	self._properties = properties
	return self
end

function TweenServiceManager:SetEase(easeStyle, easeDirection)
	self._tweenInfo = TweenInfo.new(
		self._tweenInfo.Time,
		easeStyle or self._tweenInfo.EasingStyle,
		easeDirection or self._tweenInfo.EasingDirection,
		self._tweenInfo.RepeatCount,
		self._tweenInfo.Reverses,
		self._tweenInfo.DelayTime
	)
	return self
end

function TweenServiceManager:SetDuration(duration)
	self._tweenInfo = TweenInfo.new(
		duration,
		self._tweenInfo.EasingStyle,
		self._tweenInfo.EasingDirection,
		self._tweenInfo.RepeatCount,
		self._tweenInfo.Reverses,
		self._tweenInfo.DelayTime
	)
	return self
end

function TweenServiceManager:SetDelay(delay)
	self._tweenInfo = TweenInfo.new(
		self._tweenInfo.Time,
		self._tweenInfo.EasingStyle,
		self._tweenInfo.EasingDirection,
		self._tweenInfo.RepeatCount,
		self._tweenInfo.Reverses,
		delay
	)
	return self
end

function TweenServiceManager:SetLoops(loops, loopType)
	self._tweenInfo = TweenInfo.new(
		self._tweenInfo.Time,
		self._tweenInfo.EasingStyle,
		self._tweenInfo.EasingDirection,
		loops,
		(loopType == "YoYo"),
		self._tweenInfo.DelayTime
	)
	return self
end

-- 回调系统 --
function TweenServiceManager:OnStart(callback)
	table.insert(self._callbacks.OnStart, callback)
	return self
end

function TweenServiceManager:OnUpdate(callback)
	table.insert(self._callbacks.OnUpdate, callback)
	return self
end

function TweenServiceManager:OnComplete(callback)
	table.insert(self._callbacks.OnComplete, callback)
	return self
end

-- 控制方法 --
function TweenServiceManager:Play()
	if self._isPlaying then return end
	--if self._tweenInstance then
	--	self._tweenInstance:Cancel()
	--end

	--self._tweenInstance = TweenService:Create(self._target, self._tweenInfo, self._properties)

	if not self._tweenInstance then
		self._tweenInstance = TweenService:Create(self._target, self._tweenInfo, self._properties)
		
		-- 连接事件
		self._tweenInstance.Completed:Connect(function()
			for _, callback in ipairs(self._callbacks.OnComplete) do
				task.spawn(callback)
			end
			
			self._isPlaying = false
		end)
	end

	-- 设置起始值
	if self._from then
		self._from()
	end
	
	-- 启动补间
	self._isPlaying = true
	self._tweenInstance:Play()

	-- 触发开始回调
	for _, callback in ipairs(self._callbacks.OnStart) do
		task.spawn(callback)
	end

	return self
end

function TweenServiceManager:Stop()
	if self._tweenInstance then
		self._tweenInstance:Cancel()
		self._isPlaying = false
	end
	return self
end

function TweenServiceManager:Pause()
	if self._tweenInstance and self._isPlaying then
		self._tweenInstance:Pause()
		self._isPlaying = false
	end
	return self
end

function TweenServiceManager:Resume()
	if self._tweenInstance and not self._isPlaying then
		self._tweenInstance:Play()
		self._isPlaying = true
	end
	return self
end

function TweenServiceManager:IsPlaying()
	return self._isPlaying
end

return TweenServiceManager