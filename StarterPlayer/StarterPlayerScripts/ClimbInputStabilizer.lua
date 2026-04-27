local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer

local INPUT_THRESHOLD = 0.1
local RENDER_STEP_NAME = "UniversalClimbStabilizer"

local activeCharacter = nil
local activeHumanoid = nil
local controls = nil

local function refreshControls()
	local success, result = pcall(function()
		local playerScripts = localPlayer:WaitForChild("PlayerScripts")
		local playerModule = require(playerScripts:WaitForChild("PlayerModule"))
		return playerModule:GetControls()
	end)
	controls = success and result or nil
end

local function bindCharacter(character)
	activeCharacter = character
	activeHumanoid = character:WaitForChild("Humanoid")
end

local function applyClimbIntent()
	if not activeCharacter or not activeHumanoid then return end
	-- 仅在攀爬状态下介入
	if activeHumanoid:GetState() ~= Enum.HumanoidStateType.Climbing then return end

	local rootPart = activeCharacter:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	-- 1. 获取原始意图向量 (优先读取手动输入，如果没有则读取 MoveDirection 以支持 AutoPlay)
	local moveVector = Vector3.zero
	if controls then
		moveVector = controls:GetMoveVector()
	end

	-- 如果手动没输入，但角色正在移动 (说明 AutoPlay 脚本正在控制)
	if moveVector.Magnitude < INPUT_THRESHOLD then
		if activeHumanoid.MoveDirection.Magnitude > 1e-3 then
			-- 【核心转换】：将带有摄像机偏角的 MoveDirection 转换回角色的本地空间
			-- 这样我们就能知道 AutoPlay 到底想让角色“向前”还是“向后”
			local localMove = rootPart.CFrame:VectorToObjectSpace(activeHumanoid.MoveDirection)
			moveVector = Vector3.new(localMove.X, 0, localMove.Z)
		else
			-- 真正静止时，直接放权，避免干扰其他逻辑
			return 
		end
	end

	-- 2. 基于角色自身的坐标系（不带相机俯仰角）重新构建世界空间向量
	local lookVector = rootPart.CFrame.LookVector
	local flatForward = Vector3.new(lookVector.X, 0, lookVector.Z)

	if flatForward.Magnitude < 1e-3 then return end
	flatForward = flatForward.Unit
	local flatRight = Vector3.new(flatForward.Z, 0, -flatForward.X)

	local finalMoveDir = Vector3.zero

	-- 处理前后意图 (moveVector.Z 是前后轴)
	if moveVector.Z <= -INPUT_THRESHOLD then
		-- 意图：前进/向上。强制给予水平向墙的力，Roblox物理会自动转为向上攀爬。
		finalMoveDir = flatForward
	elseif moveVector.Z >= INPUT_THRESHOLD then
		-- 意图：后退/向下。给予向墙推力 + 向下的力，防止后仰脱离。
		finalMoveDir = flatForward + Vector3.new(0, -1, 0)
	end

	-- 处理左右平移 (moveVector.X 是左右轴)
	if math.abs(moveVector.X) >= INPUT_THRESHOLD then
		finalMoveDir = finalMoveDir + (flatRight * moveVector.X)
	end

	-- 3. 覆盖移动指令
	if finalMoveDir.Magnitude > 1e-3 then
		-- 必须设为 false，表示我们传入的是世界空间向量，不再受相机转动二次污染
		activeHumanoid:Move(finalMoveDir.Unit, false)
	end
end

refreshControls()
if localPlayer.Character then bindCharacter(localPlayer.Character) end
localPlayer.CharacterAdded:Connect(bindCharacter)

-- 使用高优先级绑定，确保在默认控制脚本之后执行，强行修正结果
RunService:BindToRenderStep(
	RENDER_STEP_NAME,
	Enum.RenderPriority.Character.Value + 1,
	applyClimbIntent
)

script.Destroying:Connect(function()
	RunService:UnbindFromRenderStep(RENDER_STEP_NAME)
end)