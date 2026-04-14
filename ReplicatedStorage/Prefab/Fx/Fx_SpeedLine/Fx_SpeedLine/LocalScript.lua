-- 确保此脚本是 LocalScript，并放在作为容器的 Frame 下
local RunService = game:GetService("RunService")

local container = script.Parent -- 直接使用脚本所在的父节点作为容器

-- --- 核心配置参数 ---
local LINE_COUNT = 80          -- 线条数量
local CENTER_HOLE_RADIUS = 650 -- 中间留空的半径
local LINE_LENGTH_MAX = 200    -- 线条长度
local LINE_THICKNESS = 6       -- 线条物理厚度
local COLOR = Color3.fromRGB(255, 255, 255) 
-- -------------------

local lines = {}

-- 重置线条位置的函数
local function resetLine(lineData)
	local angle = math.rad(math.random(0, 360))
	lineData.Angle = angle

	-- 从中心圆以外随机位置开始
	lineData.Distance = CENTER_HOLE_RADIUS + math.random(0, 100)
	lineData.Speed = math.random(1200, 2500)

	lineData.Instance.Rotation = math.deg(angle)
end

-- 1. 在当前节点下初始化线条
for i = 1, LINE_COUNT do
	local f = Instance.new("Frame")
	f.Name = "SpeedLine_Particle"
	f.BackgroundColor3 = COLOR
	f.BorderSizePixel = 0
	f.AnchorPoint = Vector2.new(1, 0.5) -- 锚点在末端，方便配合渐变
	f.Size = UDim2.fromOffset(0, LINE_THICKNESS)
	f.ZIndex = container.ZIndex + 1 -- 确保在父级之上
	f.Parent = container

	-- 实现一头粗一头细的渐变
	local uigradient = Instance.new("UIGradient")
	uigradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),   -- 靠近中心端：完全透明
		NumberSequenceKeypoint.new(0.5, 0.2), -- 中间过渡
		NumberSequenceKeypoint.new(1, 0)    -- 远离中心端：完全不透明
	})
	uigradient.Parent = f

	local data = {Instance = f, Angle = 0, Distance = 0, Speed = 0}
	resetLine(data)
	table.insert(lines, data)
end

-- 2. 帧更新逻辑
RunService.RenderStepped:Connect(function(dt)
	-- 如果父容器不可见，则跳过计算（优化性能）
	if not container.Visible or container.AbsoluteSize.X == 0 then 
		return 
	end

	local center = container.AbsoluteSize / 2

	for _, data in ipairs(lines) do
		-- 更新移动距离
		data.Distance = data.Distance + (data.Speed * dt)

		-- 计算散射方向
		local dir = Vector2.new(math.cos(data.Angle), math.sin(data.Angle))
		local pos = center + (dir * data.Distance)

		-- 更新位置和长度
		data.Instance.Position = UDim2.fromOffset(pos.X, pos.Y)
		data.Instance.Size = UDim2.fromOffset(LINE_LENGTH_MAX, LINE_THICKNESS)

		-- 边界检查：如果超出父容器范围则重置
		if pos.X < -LINE_LENGTH_MAX or pos.X > container.AbsoluteSize.X + LINE_LENGTH_MAX or 
			pos.Y < -LINE_LENGTH_MAX or pos.Y > container.AbsoluteSize.Y + LINE_LENGTH_MAX then
			resetLine(data)
			data.Distance = CENTER_HOLE_RADIUS -- 回到中心圆边缘
		end
	end
end)