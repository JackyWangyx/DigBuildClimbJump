local tool = script.Parent
local event = tool:WaitForChild("DigEvent")

-- --- 配置区域 ---
local digRadius = 3    -- 挖掘半径 (相当于你之前宽度的一半)
local maxDistance = 6 -- 玩家最远点击距离
-- ----------------

-- 网格对齐逻辑 (球形挖掘建议对齐到 2 或 4)
local function alignToGrid(pos)
	local size = 2 -- Roblox 地形体素大小是 4，对齐到 4 会让挖掘更稳定
	return Vector3.new(
		math.floor(pos.X / size + 0.5) * size,
		math.floor(pos.Y / size + 0.5) * size,
		math.floor(pos.Z / size + 0.5) * size
	)
end

event.OnServerEvent:Connect(function(player, rayOrigin, rayDirection)
	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {character}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	-- 射线检测
	local rayResult = workspace:Raycast(rayOrigin, rayDirection * 100, raycastParams)

	if rayResult and rayResult.Instance:IsA("Terrain") then
		local distanceToPlayer = (rayResult.Position - hrp.Position).Magnitude

		if distanceToPlayer <= maxDistance then
			-- 【球形全向挖掘逻辑】
			-- 1. 沿着视角方向往里推入一段距离，确保球心进入地形内部
			-- 这样挖掘出的洞会以你准星点击的点为“入口”
			local pushDistance = digRadius * 0.8 -- 推入半径的 80% 效果最好
			local targetCenter = rayResult.Position + (rayDirection.Unit * pushDistance)

			-- 2. 对齐网格，防止产生细碎无法挖掘的薄片
			local finalPos = alignToGrid(targetCenter)

			-- 3. 执行球形挖掘 (将地形替换为空气)
			-- 参数：中心点 (Vector3), 半径 (number), 材质 (Material)
			workspace.Terrain:FillBall(finalPos, digRadius, Enum.Material.Air)

			print("已执行球形挖掘，位置: " .. tostring(finalPos))
		end
	end
end)