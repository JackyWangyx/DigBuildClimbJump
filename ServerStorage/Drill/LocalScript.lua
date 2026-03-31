local tool = script.Parent
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local event = tool:WaitForChild("DigEvent")

local cooldown = 0.5
local lastDig = 0

tool.Activated:Connect(function()
	if tick() - lastDig < cooldown then return end

	-- 从相机发射射线
	local rayOrigin = camera.CFrame.Position
	local rayDirection = camera.CFrame.LookVector

	-- 发送给服务器：起点和方向
	event:FireServer(rayOrigin, rayDirection)

	lastDig = tick()
end)