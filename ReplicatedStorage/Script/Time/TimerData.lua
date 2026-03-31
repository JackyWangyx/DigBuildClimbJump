local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)

local TimerData = {}
TimerData.__index = TimerData

local TimerHandler = {
	activeTimers = {},
	updateConnection = nil
}

function TimerHandler.StartUpdate()
	if not TimerHandler.updateConnection then
		TimerHandler.updateConnection = UpdatorManager:Heartbeat(function(deltaTime)
			for _, timer in pairs(TimerHandler.activeTimers) do
				if timer._active and not timer._paused then
					timer:Update(deltaTime)
				end
			end
		end)
	end
end

function TimerData.New(duration, callback, options)
	options = options or {}
	local self = setmetatable({
		_duration = duration,
		_callback = callback,
		_elapsed = 0,
		_active = false,
		_paused = false,
		_loop = options.loop or false,
		_loopCount = options.loopCount or math.huge,
		_currentLoop = 0,
		_onStart = options.onStart,
		_onPause = options.onPause,
		_onResume = options.onResume,
		_onStop = options.onStop,
		_destroyed = false
	}, TimerData)
	return self
end

function TimerData:Start()
	if self._destroyed then return end
	self._active = true
	self._paused = false
	TimerHandler.activeTimers[self] = self
	TimerHandler.StartUpdate()
	if self._onStart then
		self._onStart()
	end
end

function TimerData:Pause()
	if self._active and not self._paused then
		self._paused = true
		if self._onPause then
			self._onPause()
		end
	end
end

function TimerData:Resume()
	if self._active and self._paused then
		self._paused = false
		if self._onResume then
			self._onResume()
		end
	end
end

function TimerData:Stop()
	self._active = false
	TimerHandler.activeTimers[self] = nil
	if self._onStop then
		self._onStop()
	end
end

function TimerData:TogglePause()
	if self._paused then
		self:Resume()
	else
		self:Pause()
	end
end

function TimerData:Destroy()
	self:Stop()
	self._destroyed = true
	setmetatable(self, nil)
end

function TimerData:Update(deltaTime)
	if self._destroyed then return end

	self._elapsed += deltaTime

	if self._elapsed >= self._duration then
		local success, err = pcall(self._callback)
		if not success then
			warn("Timer callback error:", err)
		end

		if self._loop then
			self._currentLoop += 1
			if self._currentLoop >= self._loopCount then
				self:Destroy()
			else
				self._elapsed = 0
			end
		else
			self:Destroy()
		end
	end
end

return TimerData