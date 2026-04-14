local UserInputService = game:GetService("UserInputService")

local InputManager = require(game.ReplicatedStorage.ScriptAlias.InputManager)

local Terrain = workspace.Terrain

local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)

local TerrainManager = {}

------------------------------------------------------------------------------------
-- Create

local DepthConfig = {
	--{Depth = 100,   Material = Enum.Material.Grass},      -- 草地表层
	{Depth = 128,   Material = Enum.Material.Ground},    -- 表土
	{Depth = 256,  Material = Enum.Material.Mud},        -- 湿土
	{Depth = 384,  Material = Enum.Material.Sand},       -- 砂层
	{Depth = 512,  Material = Enum.Material.Sandstone},  -- 砂岩
	{Depth = 640,  Material = Enum.Material.Limestone},  -- 石灰岩
	{Depth = 768,  Material = Enum.Material.Rock},       -- 普通岩石
	--{Depth = 80,  Material = Enum.Material.Slate},      -- 板岩
	{Depth = 896,  Material = Enum.Material.Basalt},     -- 玄武岩
	{Depth = 1024, Material = Enum.Material.CrackedLava},-- 高压岩层
	--{Depth = 110, Material = Enum.Material.Basalt},     -- 深层岩
	--{Depth = 120, Material = Enum.Material.Rock},       -- 深岩
	--{Depth = 130, Material = Enum.Material.Slate},      -- 基岩层
	--{Depth = 160, Material = Enum.Material.Basalt},     -- 最深层
}

function TerrainManager:Create(position, size)
	position = position or Vector3.new(0,0,0)

	local topY = position.Y + size.Y/2
	local bottomY = position.Y - size.Y/2

	local currentTop = topY
	local lastDepth = 0

	for i,layer in ipairs(DepthConfig) do

		local layerTop = -lastDepth
		local layerBottom = -layer.Depth

		local segTop = math.min(currentTop, layerTop)
		local segBottom = math.max(bottomY, layerBottom)

		if segTop > segBottom then

			local height = segTop - segBottom
			local centerY = segBottom + height/2

			local cf = CFrame.new(position.X, centerY, position.Z)
			local fillSize = Vector3.new(size.X, height, size.Z)

			Terrain:FillBlock(cf, fillSize, layer.Material)
		end

		lastDepth = layer.Depth

		if bottomY >= layerBottom then
			return
		end
	end

	local lastMaterial = DepthConfig[#DepthConfig].Material
	local deepestBottom = -DepthConfig[#DepthConfig].Depth

	if bottomY < deepestBottom then

		local segTop = math.min(currentTop, deepestBottom)
		local segBottom = bottomY

		local height = segTop - segBottom
		local centerY = segBottom + height/2

		local cf = CFrame.new(position.X, centerY, position.Z)
		local fillSize = Vector3.new(size.X, height, size.Z)

		Terrain:FillBlock(cf, fillSize, lastMaterial)
	end

end

function TerrainManager:CreateCylinder(position, radius, height)
	position = position or Vector3.new(0,0,0)

	local topY = position.Y + height/2
	local bottomY = position.Y - height/2

	local currentTop = topY
	local lastDepth = 0

	for _,layer in ipairs(DepthConfig) do

		local layerTop = -lastDepth
		local layerBottom = -layer.Depth

		local segTop = math.min(currentTop, layerTop)
		local segBottom = math.max(bottomY, layerBottom)

		if segTop > segBottom then

			local segHeight = segTop - segBottom
			local centerY = segBottom + segHeight/2

			local cf = CFrame.new(position.X, centerY, position.Z)

			Terrain:FillCylinder(
				cf,
				segHeight,
				radius,
				layer.Material
			)
		end

		lastDepth = layer.Depth

		if bottomY >= layerBottom then
			return
		end
	end

	local lastMaterial = DepthConfig[#DepthConfig].Material
	local deepestBottom = -DepthConfig[#DepthConfig].Depth

	if bottomY < deepestBottom then

		local segTop = math.min(currentTop, deepestBottom)
		local segBottom = bottomY

		local segHeight = segTop - segBottom
		local centerY = segBottom + segHeight/2

		local cf = CFrame.new(position.X, centerY, position.Z)

		Terrain:FillCylinder(
			cf,
			segHeight,
			radius,
			lastMaterial
		)
	end

end

------------------------------------------------------------------------------------
-- Dig

function TerrainManager:DigCircleCylinder(position, radius, depth)
	local height = depth or 20
	local cf = CFrame.new(position)
	Terrain:FillCylinder(cf, height, radius, Enum.Material.Air)
end

function TerrainManager:DigCircleBall(position, radius)
	Terrain:FillBall(position, radius, Enum.Material.Air)
end

------------------------------------------------------------------------------------
-- Clear

function TerrainManager:Clear()
	Terrain:Clear()
end

------------------------------------------------------------------------------------
-- Dig Control

local DIG_OFFSET = Vector3.new(0, -1.5, 0)

TerrainManager.DigRadius = 5
TerrainManager.DigRayAngle = -75
TerrainManager.DigCheckDistance = 10

function TerrainManager:InitDig(checkFunc, onSuccess, onFail)
	InputManager:HandleAction(function()
		TerrainManager:DigForward(TerrainManager.DigRadius, checkFunc, onSuccess, onFail)
	end)
end

function TerrainManager:SetDigRadius(radius)
	TerrainManager.DigRadius = radius
end

-- 向面前挖掘
function TerrainManager:DigForward(radius, checkFunc, onSuccess, onFail)
	local check = checkFunc()
	if not check then return end
	
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	local camera = workspace.CurrentCamera
	local mouse = player:GetMouse()

	local tiltedCFrame = rootPart.CFrame * CFrame.Angles(math.rad(TerrainManager.DigRayAngle), 0, 0)
	local lookDirection = tiltedCFrame.LookVector
	local rayOrigin = rootPart.Position + Vector3.new(0, 2, 0)
	local rayDirection = lookDirection * TerrainManager.DigCheckDistance

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = { character}
	rayParams.IgnoreWater = true

	local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
	if result and result.Instance == Terrain then
		local hitPos = result.Position
		TerrainManager:DigCircleBall(hitPos + DIG_OFFSET, radius)
		onSuccess(true, hitPos)
	else
		onFail(false, nil)
	end
end

-- 向下挖掘
function TerrainManager:DigDown(radius, onSuccess, onFail)
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	local camera = workspace.CurrentCamera
	local mouse = player:GetMouse()

	local rayOrigin = rootPart.Position + Vector3.new(0, -1, 0)
	local rayDirection = Vector3.new(0, -TerrainManager.DigCheckDistance, 0)

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = { character}
	rayParams.IgnoreWater = true

	local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
	if result and result.Instance == Terrain then
		local hitPos = result.Position
		TerrainManager:DigCircleBall(hitPos + DIG_OFFSET, radius)
		onSuccess(true, hitPos)
	else
		onFail(false, nil)
	end
end

return TerrainManager
