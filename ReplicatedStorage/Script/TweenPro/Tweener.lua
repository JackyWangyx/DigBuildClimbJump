local TweenMnaager = require(script.Parent.TweenManager)
local TweenEnum = require(script.Parent.TweenEnum)
local EaseUtil = require(script.Parent.Util.EaseUtil)
local LerpUtil = require(script.Parent.Util.LerpUtil)

local Tweener = {}

local IDCounter = 0
local function GenerateID()
	IDCounter += 1
	return IDCounter
end

Tweener.__index = Tweener

local DefaultParam = {
	ID = nil,
	TweenType = nil,
	Target = nil,
	From = 0,
	FromGetter = nil,
	To = 1,
	ToGetter = nil,
	Duration = 1,
	Delay = 0,
	EaseType = TweenEnum.EaseType.Linear,
	Strength = 1,
	LoopType = TweenEnum.LoopType.Onece,
	LoopCount = 1,
	AutoDeSpawn = true,
	
	TweenFunction = nil,
	OnSpawn = nil,
	OnDeSpawn = nil,
	ValueGetter = nil,
	ValueSetter = nil,
	EaseFunction = nil,
}

local DefaultState = {
	State = TweenEnum.PlayState.Stop,
	Forward = TweenEnum.ForwardType.Forward,
	Value = 0,
	PlayTimer = 0,
	DelayTimer = 0,
	NormalizedTime = 0,
	LoopCounter = 0,
}

local DefualtCallbcak = {
	OnPlay = nil,
	OnUpdate = nil,
	OnPause = nil,
	OnResume = nil,
	OnStop = nil,
	OnComplete = nil,
}

function Tweener.new(tweenType, tweenFunction, target, from, to, duration)
	local self = setmetatable({
	}, Tweener)
	self:Reset()
	self.ID = GenerateID()
	self.TweenType = tweenType
	self.TweenFunction = tweenFunction
	self.OnSpawn = tweenFunction.OnSpawn
	self.OnDeSpawn = tweenFunction.OnDeSpawn
	self.ValueGetter = tweenFunction.GetValue
	self.ValueSetter = tweenFunction.SetValue	
	self.Target = target
	self.From = from
	self.To = to
	self.Duration = duration
	
	if self.OnSpawn  then
		self.OnSpawn(self, self)
	end
	
	return self
end

local function DeSpawnInternal(tweener)
	if tweener.OnDeSpawn  then
		tweener.OnDeSpawn(tweener, tweener)
	end
	
	tweener.Target = nil
	TweenMnaager:RemoveTweener(tweener)
end

function Tweener:SetValue(value)
	if not self.ValueSetter then return end
	self.ValueSetter(self, self, self.Target, value)
end

function Tweener:Sample(normalizedTime)
	self.NormalizedTime = normalizedTime
	local factor = self.EaseFunction(self, 0, 1, self.NormalizedTime, self.Strength)
	
	local from
	if self.FromGetter ~= nil then
		from = self.FromGetter(self.Target)
	else
		from = self.From
	end
	
	local to
	if self.ToGetter ~= nil then
		to = self.ToGetter(self.Target)
	else
		to = self.To
	end
	
	self.Value = LerpUtil:LerpUnclamped(from, to, factor)
end

-- Update

function Tweener:Update(deltaTime)
	if self.State ~= TweenEnum.PlayState.Playing then return end

	-- Delay
	if self.Delay > 0 and self.DelayTimer < self.Delay then
		self.DelayTimer += deltaTime
		if self.DelayTimer < self.Delay then
			return
		end

		deltaTime = self.DelayTimer - self.Delay
		self.DelayTimer = self.Delay
	end
	
	-- /0
	if self.Duration <= 0 then self.Duration = 1e-6 end

	local dir = 1
	if self.Forward == TweenEnum.ForwardType.Backward then
		dir = -1
	end

	-- Timer
	self.PlayTimer += deltaTime * dir

	-- Overflow
	local finishedThisPass = false
	local overflow = 0

	if dir == 1 and self.PlayTimer >= self.Duration then
		overflow = self.PlayTimer - self.Duration
		self.PlayTimer = self.Duration
		finishedThisPass = true
	elseif dir == -1 and self.PlayTimer <= 0 then
		overflow = -self.PlayTimer
		self.PlayTimer = 0
		finishedThisPass = true
	end

	-- Normalized
	local normalizedTime = math.clamp(self.PlayTimer / self.Duration, 0, 1)
	self:Sample(normalizedTime)

	-- Set Value
	if self.Target and self.ValueSetter then
		self:SetValue(self.Value)
	end

	-- OnUpdate
	if self.OnUpdate then
		self.OnUpdate(self.Value, self.NormalizedTime)
	end

	-- Loop
	if finishedThisPass then
		self.LoopCounter += 1

		local loopType = self.LoopType
		local maxLoops = self.LoopCount or 1

		local isOnce = loopType == TweenEnum.LoopType.Once
		local isLoop = loopType == TweenEnum.LoopType.Loop
		local isPingPong = loopType == TweenEnum.LoopType.PingPong

		-- Loop
		local continuePlay = true
		if isOnce then
			continuePlay = false
		elseif maxLoops > 0 and self.LoopCounter >= maxLoops then
			continuePlay = false
		end

		-- Complete
		if not continuePlay then
			self.State = TweenEnum.PlayState.Complete
			if self.OnComplete then 
				self.OnComplete() 
			end
			
			if self.AutoDeSpawn then
				DeSpawnInternal(self)
			else
				self:ResetPlayState()
			end
			
			return
		end

		-- Next Loop
		if isLoop then
			if dir == 1 then
				self.PlayTimer = 0 + overflow
			else
				self.PlayTimer = self.Duration - overflow
			end
		elseif isPingPong then
			if self.Forward == TweenEnum.ForwardType.Forward then
				self.Forward = TweenEnum.ForwardType.Backward
				self.PlayTimer = self.Duration - overflow
			else
				self.Forward = TweenEnum.ForwardType.Forward
				self.PlayTimer = 0 + overflow
			end
		else
			self.State = TweenEnum.PlayState.Complete
			if self.OnComplete then 
				self.OnComplete()
			end
			
			if self.AutoDeSpawn then
				DeSpawnInternal(self)
			else
				self:ResetPlayState()
			end
			
			return
		end
	end
end

-- State

function Tweener:IsPlaying()
	return self.State == TweenEnum.PlayState.Playing
end

function Tweener:IsComplete()
	return self.State == TweenEnum.PlayState.Complete
end

-- Play / Pause / Stop

function Tweener:Play()
	if self.State == TweenEnum.PlayState.Playing then
		return
	elseif self.State == TweenEnum.PlayState.Stop then
		self.State = TweenEnum.PlayState.Playing
		if self.OnPlay then
			self.OnPlay()
		end
		
		self:SetValue(self.From)
		TweenMnaager:AddTweener(self)
	elseif self.State == TweenEnum.PlayState.Pasue then
		self.State = TweenEnum.PlayState.Playing
		if self.OnResume then
			self.OnResume()
		end
	end
	
	return self
end

function Tweener:Pause()
	if self.State ~= TweenEnum.PlayState.Playing then return end
	self.State = TweenEnum.PlayState.Pasue
	if self.OnPause then
		self.OnPause()
	end
	return self
end

function Tweener:Stop()
	TweenMnaager:RemoveTweener(self)
	self:ResetPlayState()

	self.State = TweenEnum.PlayState.Stop
	if self.OnStop then
		self.OnStop()
	end
	
	if not self.AutoDeSpawn then
		if self.State == TweenEnum.PlayState.Stop then
			return self
		end	
	else
		DeSpawnInternal(self)
		return self
	end
end

function Tweener:DeSpawn()
	DeSpawnInternal(self)
	return self
end

-- Set Param

function Tweener:SetTarget(target)
	self.Target = target
	return self
end

function Tweener:SetFrom(from)
	self.From = from
	return self
end

function Tweener:SetFromGetter(getter)
	self.FromGetter = getter
	return self
end

function Tweener:SetTo(to)
	self.To = to
	return self
end

function Tweener:SetToGetter(getter)
	self.ToGetter = getter
	return self
end

function Tweener:SetDuration(duration)
	self.Duration = duration
	return self
end

function Tweener:SetDelay(delayDuration)
	self.Delay = delayDuration
	return self
end

function Tweener:SetEase(easeType, strength)
	self.EaseType = easeType
	self.Strength = strength or 1
	self.EaseFunction = EaseUtil:GetEaseFunction(easeType)
	return self
end

function Tweener:SetLoop(loopType, loopCount)
	self.LoopType = loopType
	self.LoopCount = loopCount or 1
	return self
end

function Tweener:SetAutoDeSpawn(autoDeSpawn)
	self.AutoDeSpawn = autoDeSpawn
	return self
end

-- Set Callback

function Tweener:SetOnPlay(onPlay)
	self.OnPlay = onPlay
	return self
end

function Tweener:SetOnPause(onPause)
	self.OnPause = onPause
	return self
end

function Tweener:SetOnResume(onResume)
	self.OnResume = onResume
	return self
end

function Tweener:SetOnUpdate(onUpdate)
	self.OnUpdate = onUpdate
	return self
end

function Tweener:SetOnStop(onStop)
	self.OnStop = onStop
	return self
end

function Tweener:SetOnComplete(onComplete)
	self.OnComplete = onComplete
	return self
end

-- Reset

local function ResetParam(tweener, param)
	for k, v in pairs(param) do
		tweener[k] = v
	end
	return tweener
end

function Tweener:ResetPlayState()
	ResetParam(self, DefaultState)
	return self
end

function Tweener:Reset()
	self = ResetParam(self, DefaultParam)
	self = ResetParam(self, DefualtCallbcak)
	self = ResetParam(self, DefaultState)	
	self.EaseFunction = EaseUtil:GetEaseFunction(self.EaseType)
	return self
end

return Tweener
