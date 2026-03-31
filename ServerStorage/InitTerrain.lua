local terrain = workspace.Terrain

-- --- 配置参数 ---
local holeWidth = 128      -- 深坑的宽度
local holeDepth = 200     -- 深坑的总深度（向下延伸的距离）
local resolution = 1      -- 地形最小单元 (4)

-- 定义地层高度（基于 Y 轴偏移）
local layer_Soil = 0      -- 地表：土壤
local layer_Rock = -40    -- 中层：岩石
local layer_Basalt = -120 -- 深层：玄武岩
local layer_Lava = -180   -- 地心：熔岩

-- 清空旧地形（谨慎使用）
-- terrain:Clear()

-- 辅助函数：根据 Y 坐标判断材质
local function getMaterialForHeight(currentY)
	if currentY > layer_Rock then
		return Enum.Material.Ground  -- 表层土地
	elseif currentY > layer_Basalt then
		return Enum.Material.Rock    -- 中层岩石
	elseif currentY > layer_Lava then
		return Enum.Material.Basalt  -- 深层玄武岩
	else
		return Enum.Material.Lava    -- 地心熔岩
	end
end

-- 生成逻辑
for y = 0, (holeDepth / resolution) do
	local currentY = -y * resolution -- 向下计算
	local material = getMaterialForHeight(currentY)

	-- 计算该层的位置和形状
	local position = Vector3.new(0, currentY, 0)
	local size = Vector3.new(holeWidth, resolution, holeWidth)

	-- 填充地形
	terrain:FillBlock(CFrame.new(position), size, material)

	-- 每隔几层等待一下，防止卡顿
	if y % 20 == 0 then task.wait() end
end

print("深层地质结构生成完毕！")