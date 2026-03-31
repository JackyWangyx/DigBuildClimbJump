local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local UIEffect = {}

UIEffect.EffectType = {
	Rotate = "Rotate",
	Scale = "Scale",
	Shake = "Shake",
	Float = "Float",
	Bounce = "Bounce",
}

local PartEffectList = {}

-- Impl

function UIEffect:Init()
	UpdatorManager:RenderStepped(function(deltaTime)
		UIEffect:Update(deltaTime)
	end)
end

function UIEffect:HanldeUIInfo(uiInfo)
	local parts = uiInfo.UI:GetDescendants()
	for _, part in ipairs(parts) do
		UIEffect:HandlePartWithUIInfo(uiInfo, part)
	end
end

function UIEffect:HandlePartWithUIInfo(uiInfo, part)
	local partName = part.Name
	local prefix = "UIEffect_"
	if string.sub(partName, 1, #prefix) ~= prefix then
		return
	end

	local suffixType = string.sub(partName, #prefix + 1)
	local effectType = UIEffect.EffectType[suffixType]
	local effectInfo = {
		UI = uiInfo.UI,
		Part = part,
		Type = effectType,
		Value = 0,
	}

	Util:BindPartEnabled(uiInfo.UI, function()
		table.insert(PartEffectList, effectInfo)
	end, function()
		Util:ListRemove(PartEffectList, effectInfo)
	end)
end

function UIEffect:HandlePart(part, effectType)
	if not part then return end
	local effectInfo = {
		UI = nil,
		Part = part,
		Type = effectType,
		Value = 0,
	}
	
	Util:BindPartVisible(part, function()
		table.insert(PartEffectList, effectInfo)
	end, function()
		Util:ListRemove(PartEffectList, effectInfo)
	end)
end

function UIEffect:Update(deltaTime)
	for _, effectInfo in ipairs(PartEffectList) do
		local funcName = "Update"..effectInfo.Type
		local func = UIEffect[funcName]
		func(UIEffect, effectInfo, deltaTime)
	end
end

-- Effect

function UIEffect:UpdateRotate(effectInfo, deltaTime)
	effectInfo.Value = (effectInfo.Value + deltaTime * 20) % 360
	effectInfo.Part.Rotation = effectInfo.Value
end

function UIEffect:UpdateFloat(info, dt)
	-- 参数
	local speed     = info.Speed or 0.5    -- 浮动速度 (次/秒)
	local amplitude = info.Amplitude or 0.015 -- 振幅 (屏幕高度的比例, 0.02 = 上下2%)

	-- 初始化
	if not info.BasePos then
		info.BasePos = info.Part.Position
		info.Time    = math.random() * 10 -- 随机初相位，避免所有对象一起浮动
	end

	-- 累积时间
	info.Time += dt

	-- 正弦波计算 (y方向偏移)
	local omega  = 2 * math.pi * speed
	local offset = math.sin(info.Time * omega) * amplitude

	-- 应用位置 (基于 Scale 偏移，不再依赖像素 Offset)
	local base = info.BasePos
	info.Part.Position = UDim2.new(
		base.X.Scale,
		base.X.Offset,
		base.Y.Scale + offset,
		base.Y.Offset
	)
end

function UIEffect:UpdateShake(effectInfo, deltaTime)
	-- 参数（可以根据需要调）
	local sequence = {
		{ time = 0.08, angle = -20 },  -- 快速往左
		{ time = 0.16, angle = 15 },   -- 回到右
		{ time = 0.24, angle = -12 },  -- 再往左
		{ time = 0.32, angle = 10 },   -- 再回右
		{ time = 0.40, angle = -6 },   -- 最后小幅左
		{ time = 0.48, angle = 0 },    -- 归位
		{ time = 1.2, angle = 0 },     -- 停顿（比之前略长）
	}

	if not effectInfo.BaseRotation then
		effectInfo.BaseRotation = effectInfo.Part.Rotation
		effectInfo.StateTime = 0
	end

	effectInfo.StateTime = (effectInfo.StateTime + deltaTime) % sequence[#sequence].time

	-- 找到当前所处的 keyframe 区间
	for i = 1, #sequence - 1 do
		local kf1 = sequence[i]
		local kf2 = sequence[i + 1]

		if effectInfo.StateTime >= kf1.time and effectInfo.StateTime < kf2.time then
			local alpha = (effectInfo.StateTime - kf1.time) / (kf2.time - kf1.time)
			local angle = kf1.angle + (kf2.angle - kf1.angle) * alpha
			effectInfo.Part.Rotation = effectInfo.BaseRotation + angle
			break
		end
	end
end

function UIEffect:UpdateScale(effectInfo, deltaTime)
	effectInfo.Value = (effectInfo.Value + deltaTime * 2) % (2 * math.pi)
	local scale = 1 + math.sin(effectInfo.Value) * 0.1
	local baseSize = effectInfo.BaseSize

	if not baseSize then
		effectInfo.BaseSize = effectInfo.Part.Size
		baseSize = effectInfo.BaseSize
	end

	effectInfo.Part.Size = UDim2.new(
		baseSize.X.Scale * scale,
		baseSize.X.Offset * scale,
		baseSize.Y.Scale * scale,
		baseSize.Y.Offset * scale
	)
end

function UIEffect:UpdateBounce(info, dt)
	-- ==== 参数 ====
	local g            = info.Gravity       or 600    -- 像素/s^2
	local bounceFactor = info.BounceFactor  or 0.6
	local stopV        = info.StopThreshold or 10     -- 建议 5~20，单位：像素/s
	local pauseTime    = info.PauseTime     or 1      -- 秒
	local initialUpV   = info.InitialUpV    or 150    -- 每轮开始向上初速度（像素/s）

	-- ==== 初始化 ====
	if not info.BasePos then
		info.BasePos  = info.Part.Position
		info.State    = "Bounce"          -- "Bounce" / "Pause"
		info.Velocity = -initialUpV       -- 向上为负
		info.OffsetY  = 0
		info.StateTime= 0
	end

	-- 把这一帧的时间吃干净，确保状态切换后剩余时间继续生效
	local remaining = dt
	-- 可选：限制子步长，避免大 dt 时“穿地”
	local MAX_SUBSTEP = 1/120

	while remaining > 0 do
		if info.State == "Bounce" then
			-- 用较小子步整合，提升稳定性
			local step = math.min(remaining, MAX_SUBSTEP)
			remaining -= step

			-- 简单双显式欧拉
			info.Velocity = info.Velocity + g * step
			info.OffsetY  = info.OffsetY  + info.Velocity * step

			-- 触地（基准为 0；正值表示往下越过了地面）
			if info.OffsetY > 0 then
				-- 贴地
				info.OffsetY  = 0
				info.Velocity = -info.Velocity * bounceFactor

				-- 速度太小 -> 进入暂停
				if math.abs(info.Velocity) < stopV then
					info.Velocity  = 0
					info.State     = "Pause"
					-- 关键：不要丢弃这帧剩余时间，继续在 Pause 里消耗
					-- 这里不直接加 StateTime，交给下面 while 的 Pause 分支去消耗 remaining
				end
			end

		else -- "Pause"
			-- 需要的剩余停顿时间
			local need = pauseTime - info.StateTime
			if need <= 0 then
				-- 立刻开启下一轮弹跳，并继续用掉 remaining
				info.State     = "Bounce"
				info.Velocity  = -initialUpV
				info.OffsetY   = 0
				info.StateTime = 0
			else
				-- 消耗本帧 remaining 的一部分到 Pause
				local use = math.min(remaining, need)
				info.StateTime = info.StateTime + use
				remaining      = remaining - use

				-- 如果刚好/已经达到停顿时间，下一轮立刻开始（仍然在同一帧里继续模拟剩余时间）
				if info.StateTime >= pauseTime then
					info.State     = "Bounce"
					info.Velocity  = -initialUpV
					info.OffsetY   = 0
					info.StateTime = 0
				end
			end
		end
	end

	-- 应用位置（基于 OffsetY 的像素位移）
	local b = info.BasePos
	info.Part.Position = UDim2.new(b.X.Scale, b.X.Offset, b.Y.Scale, b.Y.Offset + info.OffsetY)
end



return UIEffect
