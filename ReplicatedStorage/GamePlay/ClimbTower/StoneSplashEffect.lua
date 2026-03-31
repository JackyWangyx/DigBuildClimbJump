-- StoneSplashEffect.lua (ModuleScript)
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local StoneSplashEffect = {}
StoneSplashEffect.__index = StoneSplashEffect

local SpawnPosOffset = Vector3.new(0,-10,0 )

-- ==================== 可调节参数（默认值） ====================
local DEFAULT_SETTINGS = {
	SPAWN_INTERVAL = 0.025,      -- 发射频率（秒）
	MIN_SIZE = 0.3,
	MAX_SIZE = 0.8,
	EXPLOSION_FORCE = 30,
	ROTATION_SPEED = 60,
	STONE_LIFETIME = 1.0,

	-- 颜色池（支持任意数量）
	COLOR_PALETTE = {
		Color3.fromRGB(170, 85, 0),   -- 橙褐
		Color3.fromRGB(206, 103, 0),
		Color3.fromRGB(99, 50, 0),
		Color3.fromRGB(186, 118, 0),
		-- Color3.fromRGB(255, 0, 0), -- 示例：可自行添加红色等
	},

	MATERIAL = Enum.Material.Slate,
}

-- ==================== 模块方法 ====================

-- 创建一个新的碎石特效实例
function StoneSplashEffect.new()
	local self = setmetatable({}, StoneSplashEffect)

	self._settings = table.clone(DEFAULT_SETTINGS)   -- 每个实例可独立修改参数
	self._running = false
	self._connection = nil
	self._emitterPart = nil   -- 可选：如果你想绑定到一个可见的 Part 上

	return self
end

-- ==================== 开始特效 ====================
-- 参数说明：
--   position: Vector3     -- 碎石生成的中心位置（必填）
--   size: Vector3?        -- 可选，发射区域大小（默认 Vector3.new(4, 0.2, 4)）
--   customSettings: table? -- 可选，覆盖默认参数（如颜色池、力度等）
function StoneSplashEffect:Start(position: Vector3, size: Vector3?, customSettings: table?)
	if self._running then
		self:Stop()   -- 先停止旧的，避免重复
	end

	-- 合并自定义设置
	if customSettings then
		for k, v in pairs(customSettings) do
			if self._settings[k] ~= nil then
				self._settings[k] = v
			end
		end
	end

	local settings = self._settings
	local spawnSize = size or Vector3.new(4, 0.2, 4)   -- 默认发射区域

	-- 创建一个临时的不可见发射器 Part（推荐 Parent Last）
	local emitter = Instance.new("Part")
	emitter.Name = "StoneSplashEmitter"
	emitter.Size = spawnSize
	emitter.Transparency = 1
	emitter.CanCollide = false
	emitter.Anchored = true
	emitter.Position = position + SpawnPosOffset
	emitter.Parent = workspace   -- 最后再 Parent

	self._emitterPart = emitter

	self._running = true

	-- 启动循环
	self._connection = RunService.Heartbeat:Connect(function()
		if not self._running then return end

		task.wait(settings.SPAWN_INTERVAL)   -- 控制发射频率

		-- 1. 计算边缘生成位置
		local w, d = emitter.Size.X / 2, emitter.Size.Z / 2
		local localPos = Vector3.new(0, 0, 0)
		local edge = math.random(1, 4)

		if edge == 1 then
			localPos = Vector3.new(math.random(-w, w), 0, d)
		elseif edge == 2 then
			localPos = Vector3.new(math.random(-w, w), 0, -d)
		elseif edge == 3 then
			localPos = Vector3.new(-w, 0, math.random(-d, d))
		else
			localPos = Vector3.new(w, 0, math.random(-d, d))
		end

		local worldPos = emitter.CFrame * localPos

		-- 2. 创建碎石（不要先 Parent）
		local stone = Instance.new("Part")

		-- 3. 设置属性
		local s = math.random(settings.MIN_SIZE * 10, settings.MAX_SIZE * 10) / 4
		stone.Size = Vector3.new(s, s, s)

		-- 随机颜色
		if #settings.COLOR_PALETTE > 0 then
			local idx = math.random(1, #settings.COLOR_PALETTE)
			stone.Color = settings.COLOR_PALETTE[idx]
		end

		stone.Material = settings.MATERIAL

		stone.CanCollide = false
		stone.CanTouch = false
		stone.CanQuery = false
		stone.Massless = true

		-- 初始朝向
		stone.CFrame = CFrame.new(worldPos) * CFrame.Angles(
			math.rad(math.random(0, 360)),
			math.rad(math.random(0, 360)),
			math.rad(math.random(0, 360))
		)

		-- 初速度 + 角速度
		local outwardDir = (worldPos - emitter.Position).Unit
		stone.AssemblyLinearVelocity = (outwardDir + Vector3.new(0, 2.4, 0)) * settings.EXPLOSION_FORCE

		stone.AssemblyAngularVelocity = Vector3.new(
			math.random(-settings.ROTATION_SPEED, settings.ROTATION_SPEED),
			math.random(-settings.ROTATION_SPEED, settings.ROTATION_SPEED),
			math.random(-settings.ROTATION_SPEED, settings.ROTATION_SPEED)
		)

		-- 4. 最后 Parent（消除创建延迟）
		stone.Parent = workspace

		-- 5. 自动清理
		Debris:AddItem(stone, settings.STONE_LIFETIME)
	end)
end

-- ==================== 停止特效 ====================
function StoneSplashEffect:Stop()
	self._running = false

	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end

	if self._emitterPart then
		self._emitterPart:Destroy()
		self._emitterPart = nil
	end
end

-- ==================== 获取/修改设置（可选） ====================
function StoneSplashEffect:GetSettings()
	return table.clone(self._settings)
end

function StoneSplashEffect:SetSettings(newSettings: table)
	for k, v in pairs(newSettings) do
		if self._settings[k] ~= nil then
			self._settings[k] = v
		end
	end
end

return StoneSplashEffect