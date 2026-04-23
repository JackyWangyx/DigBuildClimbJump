-- 确保此脚本是 LocalScript，并放在作为容器的 Frame 下
local RunService = game:GetService("RunService")

local container = script.Parent 
container.ClipsDescendants = true 

-- --- 核心配置参数 ---
local LINE_COUNT = 80          
local HOLE_SCALE_Y = 0.6      -- 纵向(高)的空洞大小 (0.5为到达边界)
local HOLE_STRETCH_X = 1.6     -- 横向拉伸倍数 (1为正圆，>1则横向更宽)
local LENGTH_SCALE = 0.15      
local LINE_THICKNESS_PX = 4    
local COLOR = Color3.fromRGB(255, 255, 255) 

local MIN_SPEED = 0.8
local MAX_SPEED = 2.0
-- -------------------

local lines = {}

-- 重置线条位置的函数
local function resetLine(lineData)
	local angle = math.rad(math.random(0, 360))
	lineData.Angle = angle

	-- 这里的 Distance 是一个基础比例值
	lineData.Distance = 1.0 + (math.random() * 0.2)
	lineData.Speed = MIN_SPEED + (math.random() * (MAX_SPEED - MIN_SPEED))

	-- 旋转角度依然根据原角度计算，保持指向中心
	lineData.Instance.Rotation = math.deg(angle)
end

-- 1. 初始化线条
for i = 1, LINE_COUNT do
	local f = Instance.new("Frame")
	f.Name = "SpeedLine_Elliptical"
	f.BackgroundColor3 = COLOR
	f.BorderSizePixel = 0
	f.AnchorPoint = Vector2.new(1, 0.5) 
	f.Size = UDim2.new(LENGTH_SCALE, 0, 0, LINE_THICKNESS_PX)
	f.ZIndex = container.ZIndex + 1
	f.Parent = container

	local uigradient = Instance.new("UIGradient")
	uigradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.6, 0.2), 
		NumberSequenceKeypoint.new(1, 0)
	})
	uigradient.Parent = f

	local data = {Instance = f, Angle = 0, Distance = 0, Speed = 0}
	resetLine(data)
	table.insert(lines, data)
end

-- 2. 帧更新逻辑
RunService.RenderStepped:Connect(function(dt)
	if not container.Visible then return end

	local screenSize = container.AbsoluteSize
	if screenSize.X == 0 or screenSize.Y == 0 then return end
	local aspectRatio = screenSize.X / screenSize.Y

	for _, data in ipairs(lines) do
		-- 更新移动进度
		data.Distance = data.Distance + (data.Speed * dt)

		-- 计算散射方向向量
		local dirX = math.cos(data.Angle)
		local dirY = math.sin(data.Angle)

		-- 【核心修改：椭圆逻辑】
		-- 1. Y轴位置基于基础空洞大小
		-- 2. X轴位置在Y轴基础上乘以 HOLE_STRETCH_X，并修正屏幕比例
		-- 这样中心点就会形成一个横向较长、纵向较短的椭圆
		local posX = 0.5 + (dirX * data.Distance * HOLE_SCALE_Y * HOLE_STRETCH_X) / aspectRatio
		local posY = 0.5 + (dirY * data.Distance * HOLE_SCALE_Y)

		data.Instance.Position = UDim2.fromScale(posX, posY)

		-- 边界检查：根据拉伸后的最大可能距离来重置 (1.5倍足够飞出屏幕)
		if data.Distance > (1.5 / HOLE_SCALE_Y) then
			resetLine(data)
			data.Distance = 1.0 -- 回到起始椭圆边缘
		end
	end
end)