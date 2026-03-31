local TweenService = game:GetService("TweenService")

local TweenServiceManager = require(game.ReplicatedStorage.ScriptAlias.TweenServiceManager)
local TweenManager = require(game.ReplicatedStorage.ScriptAlias.TweenManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local TweenFlyUtil = require(game.ReplicatedStorage.ScriptAlias.TweenFlyUtil)

local TweenUtil = {}

local UI_ANIMATION_DURATION = 0.25
local ANIMATION_DURATION    = 0.5

local SpinAngles5 = {36, 108, 180, 252, 324}
local SpinAngles8 = {360, 45, 90, 135, 180, 225, 270, 315}

-------------------------------------------------------------------------------------------
-- Spin

function TweenUtil:Spin(part, spinCount, targetIndex, onDone)
	local spinAngleList = nil
	if spinCount == 5 then
		spinAngleList = SpinAngles5
	elseif spinCount == 8 then
		spinAngleList = SpinAngles8
	end
	
	if not spinAngleList then return end
	local randomPrize   = spinAngleList[targetIndex]
	local totalSpins    = math.random(5, 8) * 360
	local finalRotation = totalSpins + randomPrize

	local tweener = TweenServiceManager.New(part)
		:From(function()
			part.Rotation = 0
		end)
		:To({
			Rotation = finalRotation
		})
		:SetDuration(math.random(3, 4))
		:SetEase(Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		:OnComplete(onDone)
		:Play()
	return tweener
end

-------------------------------------------------------------------------------------------
-- Shake

-- EggShake：3 秒内做 3 次抖动，每次 1 秒，频次更高，幅度逐渐减小
function TweenUtil:EggShake(part, onDone)
	local intensities = {10, 20, 40}  -- 三次抖动的最大振幅
	local perShake    = 1             -- 每次抖动时长 1 秒
	-- 增加往返次数，先剧烈来回 3 次，再逐步减弱
	local factors     = {
		1, -1, 1, -1, 1, -1,        -- 三次高频往返
		0.75, -0.75,                -- 次级往返
		0.5, -0.5,                  -- 再次往返
		0.25, -0.25,                -- 轻微往返
		0                           -- 回归静止
	}
	local stepTime = perShake / #factors  -- 每段时长

	for _, amp in ipairs(intensities) do
		local lastAngle = 0
		for _, f in ipairs(factors) do
			local target = amp * f
			TweenUtil:AngleZ(part, lastAngle, target, stepTime)
			task.wait(stepTime)
			lastAngle = target
		end
	end

	if onDone then onDone() end
end

-- 🆕 适配模型整体抖动（Viewport用）
function TweenUtil:EggShakeModel(model)
	if not model then return end

	local totalDuration = 2.5          -- 总时长3秒
	local stageShakeTimes = {10, 15, 20} -- 每段小抖动次数（可以自定义）
	local maxShakeAngles = {10, 20, 30} -- 每段最大初始角度（可以自定义）

	local originalCFrames = {}
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			originalCFrames[part] = part.CFrame
		end
	end

	-- 🧮 先算总的小抖动次数
	local totalShakeTimes = 0
	for _, times in ipairs(stageShakeTimes) do
		totalShakeTimes += times
	end

	-- 每个小抖动的时间（每次来回）
	local perShakeDuration = totalDuration / totalShakeTimes

	-- 开始逐段抖动
	for stage = 1, #stageShakeTimes do
		local times = stageShakeTimes[stage]
		local maxAngle = maxShakeAngles[stage]

		for i = 1, times do
			local progress = (i - 1) / (times - 1) -- 从0到1，控制减弱
			local currentAngle = maxAngle * (1 - progress) -- 当前小抖动角度

			local direction = if i % 2 == 0 then 1 else -1
			local angle = math.rad(currentAngle * direction)
			local offsetRotation = CFrame.Angles(0, 0, angle)

			-- 平滑到偏移
			local startTime = os.clock()
			while os.clock() - startTime < perShakeDuration/2 do
				local alpha = (os.clock() - startTime) / (perShakeDuration/2)
				for part, originalCFrame in pairs(originalCFrames) do
					part.CFrame = originalCFrame:Lerp(originalCFrame * offsetRotation, alpha)
				end
				task.wait()
			end

			-- 平滑回到原位
			local startTime2 = os.clock()
			while os.clock() - startTime2 < perShakeDuration/2 do
				local alpha = (os.clock() - startTime2) / (perShakeDuration/2)
				for part, originalCFrame in pairs(originalCFrames) do
					part.CFrame = (originalCFrame * offsetRotation):Lerp(originalCFrame, alpha)
				end
				task.wait()
			end
		end
	end

	-- 最后强制回正
	for part, originalCFrame in pairs(originalCFrames) do
		part.CFrame = originalCFrame
	end
end

-------------------------------------------------------------------------------------------
-- Model

-- 沿 Z 轴做一次 From→To Tween
function TweenUtil:AngleZ(part, from, to, duration, onDone)
	local tweener = TweenServiceManager.New(part)
		:From(function()
			part.Orientation = Vector3.new(0, 0, from)
		end)
		:To({
			Orientation = Vector3.new(0, 0, to)
		})
		:SetDuration(duration)
		:SetEase(Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		:OnComplete(onDone)
		:Play()
	return tweener
end

-- 模型绕 Y 轴旋转
function TweenUtil:ModelRotateY(model, from, to, duration)
	local tweener = TweenUtil:Value(
		Vector3.new(0, from, 0),
		Vector3.new(0, to,   0),
		duration,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.InOut,
		function(value)
			Util:SetRotation(model, value)
		end
	)
	return tweener
end

-- 模型缩放入场
function TweenUtil:ModelZoomIn(model, duration)
	local tweener = TweenUtil:Value(
		0,
		1,
		duration,
		Enum.EasingStyle.Back,
		Enum.EasingDirection.Out,
		function(value)
			Util:SetScaleValue(model, value)
		end
	)
	
	return tweener
end

-- 模型缩放出场
function TweenUtil:ModelZoomOut(model, duration)
	local tweener = TweenUtil:Value(
		1,
		0,
		duration,
		Enum.EasingStyle.Back,
		Enum.EasingDirection.In,
		function(value)
			Util:SetScaleValue(model, value)
		end
	)
	
	return tweener
end

-------------------------------------------------------------------------------------------
-- UI

function TweenUtil:UIFlyToTarget(prefab, target, value, opts)
	return TweenFlyUtil:UIFlyToTarget(prefab, target, value, opts)
end

-------------------------------------------------------------------------------------------
-- Value

-- 通用数值插值：支持 number、Vector3、Color3
function TweenUtil:Value(from, to, duration, ...)
	if select("#", ...) == 0 then return end

	local dummyValue = nil
	-- 创建对应的 Value 对象
	if typeof(from) == "number" then
		dummyValue = Instance.new("NumberValue")
	elseif typeof(from) == "Vector3" then
		dummyValue = Instance.new("Vector3Value")
	elseif typeof(from) == "Color3" then
		dummyValue = Instance.new("Color3Value")
	else
		return
	end

	-- 解析参数：可能传 (callback) 或 (easingStyle, easingDir, callback)
	local args        = table.pack(...)
	local callback    = nil
	local easeType    = Enum.EasingStyle.Linear
	local easeDir     = Enum.EasingDirection.InOut

	if #args == 1 and typeof(args[1]) == "function" then
		callback = args[1]
	elseif #args == 3 then
		if typeof(args[1]) == "EnumItem" then easeType = args[1] end
		if typeof(args[2]) == "EnumItem" then easeDir  = args[2] end
		if typeof(args[3]) == "function" then callback  = args[3] end
	end

	-- 绑定 ValueChanged 回调
	if callback then
		dummyValue:GetPropertyChangedSignal("Value"):Connect(function()
			callback(dummyValue.Value)
		end)
	end

	-- 播放 Tween
	local tweener = TweenServiceManager.New(dummyValue)
		:From(function()
			dummyValue.Value = from
		end)
		:To({
			Value = to
		})
		:SetDuration(duration)
		:SetEase(easeType, easeDir)
		:OnComplete(function()
			--dummyValue:Destroy()
		end)
		:Play()
	return tweener
end


return TweenUtil