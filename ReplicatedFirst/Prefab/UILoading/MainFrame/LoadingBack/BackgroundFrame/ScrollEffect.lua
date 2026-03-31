local imageLabel = script.Parent:WaitForChild("BackgroundTile")

-- ✅ Debug：确认启动
--print("Scroll script running...")

local speed = -25 -- 每秒像素数
local startPos = UDim2.new(0, 0, 0, 0)
imageLabel.Position = startPos

-- ✅ 获取 Offset 尺寸（必须明确）
local imageWidth = imageLabel.Size.X.Offset
local imageHeight = imageLabel.Size.Y.Offset

-- ❗ 如果为 0，说明你用了 Scale 设置，建议改为像素大小
if imageWidth == 0 or imageHeight == 0 then
	--warn("ImageLabel.Size 使用了 Scale，导致无法滚动。请改为 Offset 形式。")
end

-- 偏移追踪
local offsetX = 0
local offsetY = 0

game:GetService("RunService").RenderStepped:Connect(function(dt)
	offsetX += speed * dt
	offsetY += speed * dt

	imageLabel.Position = UDim2.new(0, offsetX, 0, offsetY)

	if offsetX >= imageWidth / 2 or offsetY >= imageHeight / 2 then
		offsetX, offsetY = 0, 0
		imageLabel.Position = startPos
	end
end)
