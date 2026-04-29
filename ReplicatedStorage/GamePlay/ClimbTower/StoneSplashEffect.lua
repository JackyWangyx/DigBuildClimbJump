-- StoneSplashEffect.lua (ModuleScript) - 高性能重构版
local RunService = game:GetService("RunService")

local StoneSplashEffect = {}
StoneSplashEffect.__index = StoneSplashEffect

local SpawnPosOffset = Vector3.new(0, -10, 0)

-- ==================== 可调节参数 ====================
local DEFAULT_SETTINGS = {
	SPAWN_INTERVAL = 0.025,      -- 发射频率（秒）
	MIN_SIZE = 0.3,
	MAX_SIZE = 0.8,
	EXPLOSION_FORCE = 30,
	ROTATION_SPEED = 60,
	STONE_LIFETIME = 1.0,

	COLOR_PALETTE = {
		Color3.fromRGB(170, 85, 0),   -- 橙褐
		Color3.fromRGB(206, 103, 0),
		Color3.fromRGB(99, 50, 0),
		Color3.fromRGB(186, 118, 0),
	},

	MATERIAL = Enum.Material.Slate,
}

-- ==================== 内置轻量级对象池 ====================
-- 将闲置的碎石存放在此处，避免反复 Instance.new 和 Destroy
local StonePool = {}
local function GetStoneFromPool()
	if #StonePool > 0 then
		return table.remove(StonePool)
	end

	-- 如果池子空了，则新建一个
	local stone = Instance.new("Part")
	stone.Name = "SplashStone"
	stone.CanCollide = false
	stone.CanTouch = false
	stone.CanQuery = false
	stone.Massless = true
	return stone
end

local function ReturnStoneToPool(stone)
	-- 重置物理状态并隐藏
	stone.AssemblyLinearVelocity = Vector3.zero
	stone.AssemblyAngularVelocity = Vector3.zero
	stone.Parent = nil
	table.insert(StonePool, stone)
end


-- ==================== 模块方法 ====================
function StoneSplashEffect.new()
	local self = setmetatable({}, StoneSplashEffect)

	self._settings = table.clone(DEFAULT_SETTINGS)
	self._running = false
	self._connection = nil
	self._accumulator = 0 -- 引入时间累加器

	return self
end

function StoneSplashEffect:Start(position: Vector3, size: Vector3?, customSettings: table?)
	if self._running then
		self:Stop()
	end

	if customSettings then
		for k, v in pairs(customSettings) do
			if self._settings[k] ~= nil then
				self._settings[k] = v
			end
		end
	end

	local settings = self._settings
	local spawnSize = size or Vector3.new(4, 0.2, 4)

	-- 使用纯数学计算替代创建实体 Emitter Part
	local baseCFrame = CFrame.new(position + SpawnPosOffset)
	local halfWidth = spawnSize.X / 2
	local halfDepth = spawnSize.Z / 2

	self._running = true
	self._accumulator = 0

	-- 启动循环 (使用 dt 累加器，杜绝挂起线程)
	self._connection = RunService.Heartbeat:Connect(function(dt)
		if not self._running then return end

		self._accumulator += dt

		-- 当累加时间达到生成间隔时，执行生成（应对掉帧时的一帧多次生成）
		while self._accumulator >= settings.SPAWN_INTERVAL do
			self._accumulator -= settings.SPAWN_INTERVAL

			-- 1. 纯数学计算边缘生成位置
			local localPos = Vector3.zero
			local edge = math.random(1, 4)

			if edge == 1 then
				localPos = Vector3.new(math.random(-halfWidth, halfWidth), 0, halfDepth)
			elseif edge == 2 then
				localPos = Vector3.new(math.random(-halfWidth, halfWidth), 0, -halfDepth)
			elseif edge == 3 then
				localPos = Vector3.new(-halfWidth, 0, math.random(-halfDepth, halfDepth))
			else
				localPos = Vector3.new(halfWidth, 0, math.random(-halfDepth, halfDepth))
			end

			local worldPos = (baseCFrame * CFrame.new(localPos)).Position

			-- 2. 从对象池获取碎石
			local stone = GetStoneFromPool()

			-- 3. 设置属性
			local s = math.random(settings.MIN_SIZE * 10, settings.MAX_SIZE * 10) / 4
			stone.Size = Vector3.new(s, s, s)

			if #settings.COLOR_PALETTE > 0 then
				local idx = math.random(1, #settings.COLOR_PALETTE)
				stone.Color = settings.COLOR_PALETTE[idx]
			end
			stone.Material = settings.MATERIAL

			-- 初始朝向
			stone.CFrame = CFrame.new(worldPos) * CFrame.Angles(
				math.rad(math.random(0, 360)),
				math.rad(math.random(0, 360)),
				math.rad(math.random(0, 360))
			)

			-- 初速度 + 角速度
			local outwardDir = (worldPos - baseCFrame.Position).Unit
			stone.AssemblyLinearVelocity = (outwardDir + Vector3.new(0, 2.4, 0)) * settings.EXPLOSION_FORCE
			stone.AssemblyAngularVelocity = Vector3.new(
				math.random(-settings.ROTATION_SPEED, settings.ROTATION_SPEED),
				math.random(-settings.ROTATION_SPEED, settings.ROTATION_SPEED),
				math.random(-settings.ROTATION_SPEED, settings.ROTATION_SPEED)
			)

			-- 4. 放入场景渲染
			stone.Parent = workspace

			-- 5. 自动清理：使用 task.delay 替代 Debris，生命周期结束后回收到池子
			task.delay(settings.STONE_LIFETIME, function()
				ReturnStoneToPool(stone)
			end)
		end
	end)
end

function StoneSplashEffect:Stop()
	self._running = false

	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end
end

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