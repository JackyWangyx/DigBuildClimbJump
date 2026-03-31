local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService") -- 获取屏幕坐标/点击事件
local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local GuiService = game:GetService("GuiService")

local ClickFx = {}

-- ============ 可调参数 ============
local BURST_COUNT        = 8           -- 每次爆出的方片数量
local SIZE_MIN, SIZE_MAX = 12, 28        -- 方片像素尺寸范围
local SPEED_MIN, SPEED_MAX = 360, 720   -- 初速度(像素/秒)
local UP_BIAS_DEG        = 65           -- 上抛偏置(以垂直向上为中心的扇形半角)
local GRAVITY            = 900          -- 重力加速度(像素/秒²)，越大落得越快
local AIR_DRAG           = 2.0          -- 简单空气阻力(越大越快减速)
local LIFE_MIN, LIFE_MAX = 0.8, 1.2     -- 寿命秒：到时开始快速淡出并移除
local ROT_SPEED_MIN, ROT_SPEED_MAX = -240, 240 -- 旋转速度(度/秒)
local MAX_ACTIVE         = 1000         -- 安全上限，防止极端连点堆积
local COLORS = {                        -- 颜色池
	Color3.fromRGB(255, 70, 70),
	Color3.fromRGB(255, 220, 70),
	Color3.fromRGB(70, 200, 255),
	Color3.fromRGB(70, 255, 140),
	Color3.fromRGB(70, 120, 255),
	Color3.fromRGB(255, 120, 220)
}

-- ============ GUI 容器 ============
local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.IgnoreGuiInset = true  -- 用原生屏幕像素坐标
screenGui.ResetOnSpawn = false
screenGui.Name = "ClickFxFrame"
screenGui.Parent = pg
screenGui.DisplayOrder = 100000

-- ============ 粒子容器与更新器 ============
local particles = {}      -- 存活粒子列表
local activeCount = 0

-- 创建一个方片粒子
local function makeSquare(startPos: Vector2)
	if activeCount >= MAX_ACTIVE then return end

	-- 随机尺寸/颜色
	local sizePx = math.random(SIZE_MIN, SIZE_MAX)
	local color = COLORS[math.random(1, #COLORS)]

	-- GUI对象
	local f = Instance.new("Frame")
	f.Size = UDim2.fromOffset(sizePx, sizePx)
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Position = UDim2.fromOffset(startPos.X, startPos.Y)
	f.BackgroundColor3 = color
	f.BorderSizePixel = 0
	f.Rotation = math.random(0, 359)
	f.BackgroundTransparency = 0
	f.Parent = screenGui
	f.ZIndex = 1000000
	
	-- 初速度：以“向上”为中心的扇形随机方向，再加少量水平散射
	-- 以 -90° 为正上方，在 [-UP_BIAS, +UP_BIAS] 内取角度
	local angleDeg = -90 + (math.random() * 2 - 1) * UP_BIAS_DEG
	local angleRad = math.rad(angleDeg)
	local speed = math.random(SPEED_MIN, SPEED_MAX)
	local v = Vector2.new(math.cos(angleRad), math.sin(angleRad)) * speed

	local rotSpeed = math.random(ROT_SPEED_MIN, ROT_SPEED_MAX)

	-- 粒子状态
	local p = {
		gui = f,
		pos = startPos,
		vel = v,
		age = 0,
		life = LIFE_MIN + math.random() * (LIFE_MAX - LIFE_MIN),
		rotSpeed = rotSpeed
	}
	table.insert(particles, p)
	activeCount += 1
end

function ClickFx:GetScreenClickPos()
	local m = UserInputService:GetMouseLocation()
	return Vector2.new(m.X, m.Y)
end

function ClickFx:SpawnFx()
	local screenPos = ClickFx:GetScreenClickPos()
	ClickFx:SpawnFxOnPos(screenPos)
end

function ClickFx:SpawnFxOnPos(pos)
	for _ = 1, BURST_COUNT do
		makeSquare(pos)
	end
end

-- 主更新循环：位置/速度/旋转/淡出
UpdatorManager:RenderStepped(function(dt)
	if activeCount == 0 then return end

	for i = #particles, 1, -1 do
		local p = particles[i]
		local f = p.gui
		if not f or not f.Parent then
			table.remove(particles, i)
			activeCount -= 1
		else
			-- 物理：重力 & 阻力
			p.vel = p.vel + Vector2.new(0, GRAVITY * dt)
			p.vel = p.vel / (1 + AIR_DRAG * dt)

			-- 移动 & 旋转
			p.pos = p.pos + p.vel * dt
			f.Position = UDim2.fromOffset(p.pos.X, p.pos.Y)
			f.Rotation = f.Rotation + p.rotSpeed * dt

			-- 寿命 & 透明度
			p.age = p.age + dt
			local t = p.age / p.life
			if t >= 1 then
				-- 快速淡出
				local alpha = math.clamp((p.age - p.life) * 3, 0, 1)
				f.BackgroundTransparency = alpha
				if alpha >= 1 or p.pos.Y > screenGui.AbsoluteSize.Y + 60 then
					f:Destroy()
					table.remove(particles, i)
					activeCount -= 1
				end
			else
				-- 先不透明，接近寿命时开始线性淡出一点点也更自然
				local preFade = math.clamp((t - 0.75) / 0.25, 0, 1)
				f.BackgroundTransparency = preFade * 0.5
			end
		end
	end
end)

return ClickFx