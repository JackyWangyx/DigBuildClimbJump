local TweenMnaager = require(script.Parent.TweenManager)
local TweenEnum = require(script.Parent.TweenEnum)
local EaseUtil = require(script.Parent.Util.EaseUtil)
local LerpUtil = require(script.Parent.Util.LerpUtil)

local Tweener = {}

Tweener.__index = Tweener

local IDCounter = 0

local function GenerateID()
	IDCounter += 1
	local id = tostring(IDCounter)
	return id
end

local LerpMap = {
	number = LerpUtil.LerpUnclampedValue,
	Vector2 = LerpUtil.LerpUnclampedVector2,
	Vector3 = LerpUtil.LerpUnclampedVector3,
	Color3 = LerpUtil.LerpUnclampedColor3,
	UDim2 = LerpUtil.LerpUnclampedUDim2,
	CFrame = LerpUtil.LerpUnclampedCFrame,
}

local TweenFunctionCache = {}

local function GetTweenFunction(tweenType)
	local cache = TweenFunctionCache[tweenType]
	if not cache then
		local scriptName = "Tween" .. tweenType
		local scriptFile = script.Parent.Tween:FindFirstChild(scriptName)
		cache = {
			ScriptName = scriptName,
			ScriptFile = scriptFile,
			TweenFunction = require(scriptFile)
		}

		TweenFunctionCache[tweenType] = cache
	end

	return cache.TweenFunction
end

function Tweener.new()
	local self = setmetatable({
	}, Tweener)
	
	self:Reset()
	return self
end

function Tweener:Init(tweenType, target, from, to, duration)
	self.ID = GenerateID()
	
	local tweenFunction = GetTweenFunction(tweenType)
	self.TweenFunction = tweenFunction
	
	if from == nil then
		from = tweenFunction:GetValue(nil, target)
	end
	
	if from then
		local typeName = typeof(from)
		self.LerpFunction = LerpMap[typeName]
	end
	
	self.EaseFunction = EaseUtil:GetEaseFunction(self.EaseType)
	
	self.TweenType = tweenType
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

	TweenMnaager:AddTweener(self)
	return self
end

local function DeSpawnInternal(tweener)
	if tweener.OnDeSpawn  then
		tweener.OnDeSpawn(tweener, tweener)
	end
	
	TweenMnaager:DeActiveTweener(tweener)
	TweenMnaager:RemoveTweener(tweener)
	
	tweener:Reset()
	if tweener.RecycleToPool then
		tweener.RecycleToPool()
	end	
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
	
	if self.LerpFunction then
		self.Value = self.LerpFunction(self, from, to, factor)
	else
		self.Value = to
	end
end

-- Update

function Tweener:Update(deltaTime)
	if self.State ~= TweenEnum.PlayState.Playing then return end

	local delayValue = self.Delay
	local duration = self.Duration

	-- Delay
	if delayValue > 0 and self.DelayTimer < delayValue then
		self.DelayTimer += deltaTime
		if self.DelayTimer < delayValue then
			return
		end

		deltaTime = self.DelayTimer - delayValue
		self.DelayTimer = delayValue
	end
	
	-- /0
	if duration <= 0 then duration = 1e-6 end

	local dir = 1
	if self.Forward == TweenEnum.ForwardType.Backward then
		dir = -1
	end

	-- Timer
	self.PlayTimer += deltaTime * dir

	-- Overflow
	local finishedThisPass = false
	local overflow = 0

	if dir == 1 and self.PlayTimer >= duration then
		overflow = self.PlayTimer - duration
		self.PlayTimer = duration
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
			self:Complete()		
			return
		end

		-- Next Loop
		if isLoop then
			if dir == 1 then
				self.PlayTimer = 0 + overflow
			else
				self.PlayTimer = duration - overflow
			end
		elseif isPingPong then
			if self.Forward == TweenEnum.ForwardType.Forward then
				self.Forward = TweenEnum.ForwardType.Backward
				self.PlayTimer = duration - overflow
			else
				self.Forward = TweenEnum.ForwardType.Forward
				self.PlayTimer = 0 + overflow
			end
		else
			self:Complete()			
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
		
		TweenMnaager:ActiveTweener(self)
	elseif self.State == TweenEnum.PlayState.Pasue then
		self.State = TweenEnum.PlayState.Playing
		if self.OnResume then
			self.OnResume()
		end
		
		TweenMnaager:ActiveTweener(self)
	end
	
	return self
end

function Tweener:Pause()
	if self.State ~= TweenEnum.PlayState.Playing then return end
	self.State = TweenEnum.PlayState.Pasue
	if self.OnPause then
		self.OnPause()
	end
	
	TweenMnaager:DeActiveTweener(self)
	return self
end

function Tweener:Complete()
	self.State = TweenEnum.PlayState.Complete
	if self.OnComplete then 
		self.OnComplete()
	end

	if self.AutoDeSpawn then
		DeSpawnInternal(self)
	else
		TweenMnaager:DeActiveTweener(self)
		self:ResetPlayState()
	end
	
	return self
end

function Tweener:Stop()
	self.State = TweenEnum.PlayState.Stop
	if self.OnStop then
		self.OnStop()
	end
	
	if self.AutoDeSpawn then
		DeSpawnInternal(self)
	else
		TweenMnaager:DeActiveTweener(self)
		self:ResetPlayState()		
	end
	
	return self
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

function Tweener:ResetPlayState()
	self.State = TweenEnum.PlayState.Stop
	self.Forward = TweenEnum.ForwardType.Forward
	self.Value = 0
	self.PlayTimer = 0
	self.DelayTimer = 0
	self.NormalizedTime = 0
	self.LoopCounter = 0
	
	return self
end

function Tweener:Reset()
	-- Param
	self.ID = nil
	self.TweenType = nil
	self.Target = nil
	self.From = 0
	self.FromGetter = nil
	self.To = 1
	self.ToGetter = nil
	self.Duration = 1
	self.Delay = 0
	self.EaseType = TweenEnum.EaseType.Linear
	self.Strength = 1
	self.LoopType = TweenEnum.LoopType.Onece
	self.LoopCount = 1
	self.AutoDeSpawn = true

	-- Interal Function
	self.OnSpawn = nil
	self.OnDeSpawn = nil
	self.ValueGetter = nil
	self.ValueSetter = nil

	self.TweenFunction = nil
	self.EaseFunction = nil
	self.LerpFunction = nil

	-- Play State
	self:ResetPlayState()

	-- Callback
	self.OnPlay = nil
	self.OnUpdate = nil
	self.OnPause = nil
	self.OnResume = nil
	self.OnStop = nil
	self.OnComplete = nil

	return self
end

return Tweener
