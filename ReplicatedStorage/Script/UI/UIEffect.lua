local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local UIEffect = {}

local UDim2_new = UDim2.new

UIEffect.EffectType = {
	Rotate = "Rotate",
	Scale  = "Scale",
	Shake  = "Shake",
	Float  = "Float",
	Bounce = "Bounce",
}

-- 分组存储（核心优化）
local EffectGroups = {
	Rotate = {},
	Scale  = {},
	Shake  = {},
	Float  = {},
	Bounce = {},
}

-- ========= Effect函数映射（避免字符串拼接） =========
local EffectFuncMap = {}

-- 全局时间（减少 sin 重复计算）
UIEffect.GlobalTime = 0

-- ========= 工具函数（O(1) 删除） =========

local function AddToGroup(list, info)
	info._index = #list + 1
	list[info._index] = info
end

local function RemoveFromGroup(list, info)
	local index = info._index
	if not index then return end

	local last = list[#list]
	list[index] = last

	if last then
		last._index = index
	end

	list[#list] = nil
	info._index = nil
end

-- ========= 初始化 =========

function UIEffect:Init()
	UpdatorManager:RenderStepped(function(deltaTime)
		UIEffect:Update(deltaTime)
	end)
end

-- ========= UI 扫描 =========

function UIEffect:HandleUIInfo(uiInfo)
	local parts = uiInfo.UI:GetDescendants()

	for i = 1, #parts do
		self:HandlePartWithUIInfo(uiInfo, parts[i])
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
	if not effectType then return end

	local list = EffectGroups[effectType]

	local effectInfo = {
		UI   = uiInfo.UI,
		Part = part,
		Type = effectType,
		Func = EffectFuncMap[effectType],
	}

	Util:BindPartEnabled(uiInfo.UI,
		function()
			AddToGroup(list, effectInfo)
		end,
		function()
			RemoveFromGroup(list, effectInfo)
		end
	)
end

function UIEffect:HandlePart(part, effectType)
	if not part then return end

	local list = EffectGroups[effectType]
	if not list then return end

	local effectInfo = {
		UI   = nil,
		Part = part,
		Type = effectType,
		Func = EffectFuncMap[effectType],
	}

	Util:BindPartVisible(part,
		function()
			AddToGroup(list, effectInfo)
		end,
		function()
			RemoveFromGroup(list, effectInfo)
		end
	)
end

-- ========= Update =========

function UIEffect:Update(deltaTime)
	self.GlobalTime += deltaTime

	-- Rotate
	local list = EffectGroups.Rotate
	for i = 1, #list do
		local info = list[i]
		info.Func(self, info, deltaTime)
	end

	-- Scale
	list = EffectGroups.Scale
	for i = 1, #list do
		local info = list[i]
		info.Func(self, info, deltaTime)
	end

	-- Shake
	list = EffectGroups.Shake
	for i = 1, #list do
		local info = list[i]
		info.Func(self, info, deltaTime)
	end

	-- Float
	list = EffectGroups.Float
	for i = 1, #list do
		local info = list[i]
		info.Func(self, info, deltaTime)
	end

	-- Bounce
	list = EffectGroups.Bounce
	for i = 1, #list do
		local info = list[i]
		info.Func(self, info, deltaTime)
	end
end

-- ========= Effect实现 =========

-- Rotate
function UIEffect:UpdateRotate(info, dt)
	info.Value = (info.Value or 0) + dt * 20
	info.Part.Rotation = info.Value % 360
end

-- Float（使用全局时间）
function UIEffect:UpdateFloat(info, dt)
	local speed     = info.Speed or 0.5
	local amplitude = info.Amplitude or 0.015

	if not info.BasePos then
		info.BasePos = info.Part.Position
		info.Phase   = math.random() * 10
	end

	local omega  = 2 * math.pi * speed
	local t      = self.GlobalTime + info.Phase
	local offset = math.sin(t * omega) * amplitude

	local base = info.BasePos
	info.Part.Position = UDim2_new(
		base.X.Scale,
		base.X.Offset,
		base.Y.Scale + offset,
		base.Y.Offset
	)
end

-- Scale
function UIEffect:UpdateScale(info, dt)
	info.Value = (info.Value or 0) + dt * 2

	local scale = 1 + math.sin(info.Value) * 0.1

	if not info.BaseSize then
		info.BaseSize = info.Part.Size
	end

	local base = info.BaseSize

	info.Part.Size = UDim2_new(
		base.X.Scale * scale,
		base.X.Offset * scale,
		base.Y.Scale * scale,
		base.Y.Offset * scale
	)
end

-- Shake
function UIEffect:UpdateShake(info, dt)
	local sequence = {
		{ time = 0.08, angle = -20 },
		{ time = 0.16, angle = 15 },
		{ time = 0.24, angle = -12 },
		{ time = 0.32, angle = 10 },
		{ time = 0.40, angle = -6 },
		{ time = 0.48, angle = 0 },
		{ time = 1.2, angle = 0 },
	}

	if not info.BaseRotation then
		info.BaseRotation = info.Part.Rotation
		info.StateTime = 0
	end

	info.StateTime = (info.StateTime + dt) % sequence[#sequence].time

	for i = 1, #sequence - 1 do
		local kf1 = sequence[i]
		local kf2 = sequence[i + 1]

		if info.StateTime >= kf1.time and info.StateTime < kf2.time then
			local alpha = (info.StateTime - kf1.time) / (kf2.time - kf1.time)
			local angle = kf1.angle + (kf2.angle - kf1.angle) * alpha
			info.Part.Rotation = info.BaseRotation + angle
			break
		end
	end
end

-- Bounce（基本保持，但结构优化）
function UIEffect:UpdateBounce(info, dt)
	local g            = info.Gravity or 600
	local bounceFactor = info.BounceFactor or 0.6
	local stopV        = info.StopThreshold or 10
	local pauseTime    = info.PauseTime or 1
	local initialUpV   = info.InitialUpV or 150

	if not info.BasePos then
		info.BasePos  = info.Part.Position
		info.State    = "Bounce"
		info.Velocity = -initialUpV
		info.OffsetY  = 0
		info.StateTime= 0
	end

	local remaining = dt
	local MAX_SUBSTEP = 1/120

	while remaining > 0 do
		local step = math.min(remaining, MAX_SUBSTEP)
		remaining -= step

		if info.State == "Bounce" then
			info.Velocity += g * step
			info.OffsetY  += info.Velocity * step

			if info.OffsetY > 0 then
				info.OffsetY  = 0
				info.Velocity = -info.Velocity * bounceFactor

				if math.abs(info.Velocity) < stopV then
					info.State = "Pause"
					info.Velocity = 0
				end
			end
		else
			info.StateTime += step
			if info.StateTime >= pauseTime then
				info.State     = "Bounce"
				info.Velocity  = -initialUpV
				info.OffsetY   = 0
				info.StateTime = 0
			end
		end
	end

	local b = info.BasePos
	
	info.Part.Position = UDim2_new(
		b.X.Scale, b.X.Offset,
		b.Y.Scale, b.Y.Offset + info.OffsetY
	)
end

-- 绑定函数
EffectFuncMap.Rotate = UIEffect.UpdateRotate
EffectFuncMap.Scale  = UIEffect.UpdateScale
EffectFuncMap.Shake  = UIEffect.UpdateShake
EffectFuncMap.Float  = UIEffect.UpdateFloat
EffectFuncMap.Bounce = UIEffect.UpdateBounce

return UIEffect