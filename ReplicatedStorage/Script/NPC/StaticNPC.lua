local npc = script.Parent

-- ===== 配置区 =====
local CONFIG = {
	ANCHOR = true,            -- 是否完全禁用物理（强烈推荐展示NPC开启）
	DISABLE_AUTO_ROTATE = true,
	FORCE_PHYSICS_STATE = true,
	SET_NETWORK_OWNER_SERVER = true,
}

local DISABLED_STATES = {
	Enum.HumanoidStateType.Running,
	Enum.HumanoidStateType.RunningNoPhysics,
	Enum.HumanoidStateType.Climbing,
	Enum.HumanoidStateType.Jumping,
	Enum.HumanoidStateType.Freefall,
	Enum.HumanoidStateType.FallingDown,
	Enum.HumanoidStateType.GettingUp,
	Enum.HumanoidStateType.Landed,
	Enum.HumanoidStateType.Swimming,
	Enum.HumanoidStateType.StrafingNoPhysics,
	Enum.HumanoidStateType.Ragdoll,
	Enum.HumanoidStateType.Flying,
	Enum.HumanoidStateType.Seated,
	Enum.HumanoidStateType.PlatformStanding,
}

-- ===== 核心逻辑 =====
local function optimizeHumanoid(humanoid)
	-- 禁用状态
	for _, state in ipairs(DISABLED_STATES) do
		humanoid:SetStateEnabled(state, false)
	end

	-- 禁止跳跃
	humanoid.JumpPower = 0
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

	-- 禁止旋转
	if CONFIG.DISABLE_AUTO_ROTATE then
		humanoid.AutoRotate = false
	end

	-- 强制状态
	if CONFIG.FORCE_PHYSICS_STATE then
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	end
end

local function optimizePhysics(model)
	local root = model:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-- 锁网络归属（避免客户端模拟）
	if CONFIG.SET_NETWORK_OWNER_SERVER then
		pcall(function()
			root:SetNetworkOwner(nil)
		end)
	end

	-- Anchor（最大性能收益）
	if CONFIG.ANCHOR then
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = true
				part.CanCollide = false -- 通常展示NPC可以关掉碰撞
			end
		end
	end
end

local function run()
	local humanoid = npc:FindFirstChildOfClass("Humanoid")
	if humanoid then
		optimizeHumanoid(humanoid)
	end

	optimizePhysics(npc)
end

-- ===== 初始化 =====
run()

-- ===== 防止NPC被重新构建（比如换装、重生）=====
npc.ChildAdded:Connect(function(child)
	if child:IsA("Humanoid") then
		task.defer(function()
			optimizeHumanoid(child)
		end)
	end
end)

npc.DescendantAdded:Connect(function(desc)
	if desc:IsA("BasePart") and CONFIG.ANCHOR then
		desc.Anchored = true
		desc.CanCollide = false
	end
end)