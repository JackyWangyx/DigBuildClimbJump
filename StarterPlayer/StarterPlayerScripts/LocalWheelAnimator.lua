local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)

local IsInGame     = false
local IsInTraining = false

EventManager:Listen(EventManager.Define.GameEnter,    function() IsInGame = true  end)
EventManager:Listen(EventManager.Define.GameLeave,    function() IsInGame = false end)
EventManager:Listen(EventManager.Define.TrainingStart,function() IsInTraining = true  end)
EventManager:Listen(EventManager.Define.TrainingEnd,  function() IsInTraining = false end)

-- StarterPlayerScripts/LocalWheelSpin.client.lua
-- 规则：
-- 1) 仅当“模型名或部件名包含大写 Wheel”时才认定为轮子；其下(或该部件本身)带 Motor6D 的 BasePart 会被驱动。
-- 2) 本地：装配线物理 > 位移估速 > 输入意图兜底；停下直接归零；无倒车（固定方向）；仅写 Motor6D.C0。
-- 3) 其他玩家：只用物理/位移估速，纯视觉；无轮子（如冰刀）→跳过，不报错不刷屏。

local Players       = game:GetService("Players")
local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)

local LP            = Players.LocalPlayer
if not game:IsLoaded() then game.Loaded:Wait() end
local character     = LP.Character or LP.CharacterAdded:Wait()

-- ===== 层级配置 =====
local CAR_NAME      = "Car"      -- 角色下的 Car
local HANDLE_NAME   = "Handle"   -- Car 下作为轮子 Part0 的 BasePart

-- ===== 旋转轴与方向 =====
local AXIS          = Vector3.new(1, 0, 0)  -- 若轮子绕 Y/Z，改为对应轴；并同步更改 getRadius 的轴
local DIR           = -1                    -- 无倒车视觉方向：选 1 或 -1

-- ===== 采样/阈值/限幅 =====
local TICK          = 0.20                  -- 5Hz 判定
local SPEED_ON      = 1.0                   -- 进入移动
local SPEED_OFF     = 1.0                   -- 退出移动
local MAX_ANGVEL    = math.rad(1080)        -- 每秒 3 圈
local R_MIN         = 1e-3

-- ===== 工具函数 =====
local function clampOmega(w:number): number
	if w >  MAX_ANGVEL then return  MAX_ANGVEL end
	if w < -MAX_ANGVEL then return -MAX_ANGVEL end
	return w
end

local function getRadius(part: BasePart): number
	local r = part:GetAttribute("WheelRadius")
	if typeof(r) == "number" and r > 0 then return r end
	-- 若换轴，改为对应尺寸的一半
	return part.Size.X * 0.5
end

-- 大小写敏感：必须包含大写 "Wheel"（不做单词边界限制，"FrontWheel" 也算）
local function nameHasCapitalWheel(str: string): boolean
	return str and string.find(str, "Wheel", 1, true) ~= nil
end

-- 结构体类型
type WheelRec = { motor: Motor6D, baseC0: CFrame, theta: number, angVel: number, radius: number }
type Rig = {
	player: Player?, char: Model, car: Model, handle: BasePart,
	wheels: {WheelRec}, isLocal: boolean, moving: boolean,
	acc: number, prevPos: Vector3, v_forward: number
}

-- ===== Rig 管理 =====
local rigs: { [Model]: Rig } = {}
local warnedOnce: { [Model]: boolean } = {}

local function findCarAndHandle(char: Model): (Model?, BasePart?)
	local car = char:FindFirstChild(CAR_NAME) or char:WaitForChild(CAR_NAME, 5)
	if not car then return nil, nil end
	local handle = car:FindFirstChild(HANDLE_NAME)
	if not (handle and handle:IsA("BasePart")) then return car, nil end
	return car, handle
end

-- 兜底：若 Motor6D 没挂在轮子 Part 下（而是在 Handle 上），尝试在 handle 下找到 Part1 = 该轮子的 Motor6D
local function findMotorForPart(part: BasePart, handle: BasePart): Motor6D?
	-- 先找挂在轮子上的
	local m = part:FindFirstChildOfClass("Motor6D")
	if m then return m end
	-- 再从 handle 下查找与该 part 连接的 Motor6D
	for _, inst in ipairs(handle:GetDescendants()) do
		if inst:IsA("Motor6D") then
			local mm = inst :: Motor6D
			if mm.Part1 == part then return mm end
		end
	end
	return nil
end

-- 统一纠正绑定并记录基准
local function addWheel(wheels: {WheelRec}, handle: BasePart, part: BasePart)
	local m = findMotorForPart(part, handle)
	if not m then return end
	m.Part0 = handle
	m.Part1 = part
	m.C0    = handle.CFrame:ToObjectSpace(part.CFrame)
	m.C1    = CFrame.new()
	table.insert(wheels, {
		motor  = m,
		baseC0 = m.C0,
		theta  = 0,
		angVel = 0,
		radius = getRadius(part),
	})
end

-- 仅识别“名字含大写 Wheel”的模型/部件
local function collectWheels(car: Model, handle: BasePart): {WheelRec}
	local wheels = {}

	-- 1) 先找名字含 Wheel 的 Model：把该模型下所有 BasePart 都当候选轮子
	for _, inst in ipairs(car:GetDescendants()) do
		if inst:IsA("Model") and nameHasCapitalWheel(inst.Name) then
			for _, sub in ipairs(inst:GetDescendants()) do
				if sub:IsA("BasePart") then
					addWheel(wheels, handle, sub)
				end
			end
		end
	end
	if #wheels > 0 then return wheels end

	-- 2) 兼容“轮子就是一个 BasePart 且名含 Wheel”的资源
	for _, inst in ipairs(car:GetDescendants()) do
		if inst:IsA("BasePart") and nameHasCapitalWheel(inst.Name) then
			addWheel(wheels, handle, inst)
		end
	end

	-- 找不到就返回空（例如冰刀），上层会跳过
	return wheels
end

local function bindWheelsFor(char: Model, isLocal: boolean, owner: Player?): Rig?
	local car, handle = findCarAndHandle(char)
	if not car or not handle then
		if not warnedOnce[char] then
			warnedOnce[char] = true
			--warn("[WheelSpin] 缺少 Car/Handle，跳过：", char:GetFullName()) 
		end
		return nil
	end

	local wheels = collectWheels(car, handle)
	if #wheels == 0 then
		-- 没有符合“Wheel”规则的轮子（比如冰刀/雪橇）→ 跳过
		return nil
	end

	return {
		player = owner, char = char, car = car, handle = handle,
		wheels = wheels, isLocal = isLocal, moving = false,
		acc = 0, prevPos = handle.Position, v_forward = 0
	}
end

local function ensureRig(char: Model, isLocal: boolean, owner: Player?)
	local rig = rigs[char]
	if rig and rig.handle and rig.handle.Parent then return rig end
	local newRig = bindWheelsFor(char, isLocal, owner)
	if newRig then rigs[char] = newRig end
	return newRig
end

local function dropRig(char: Model) rigs[char] = nil end

-- 本地
ensureRig(character, true, LP)
LP.CharacterAdded:Connect(function(newChar) character = newChar; ensureRig(newChar, true, LP) end)

-- 其他玩家
local function onPlayerAdded(p: Player)
	if p == LP then return end
	local function onChar(c: Model) ensureRig(c, false, p) end
	if p.Character then onChar(p.Character) end
	p.CharacterAdded:Connect(onChar)
	p.CharacterRemoving:Connect(dropRig)
end
for _, p in ipairs(Players:GetPlayers()) do onPlayerAdded(p) end
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(p) if p.Character then dropRig(p.Character) end end)

-- ===== 5Hz 采样（所有 rig）=====
UpdatorManager:Heartbeat(function(dt)
	for char, rig in pairs(rigs) do
		if not rig or not rig.handle or not rig.handle.Parent then
			dropRig(char)
			if char.Parent then ensureRig(char, rig and rig.isLocal or false, rig and rig.player or nil) end
		else
			rig.acc += dt
			if rig.acc >= TICK then
				local step = rig.acc; rig.acc = 0
				local h = rig.handle
				local forward = h.CFrame.LookVector

				-- 1) 物理速度
				local v_phys = h.AssemblyLinearVelocity:Dot(forward)
				-- 2) 位移估速
				local nowPos = h.Position
				local v_pos  = ((nowPos - rig.prevPos):Dot(forward)) / math.max(step, 1/240)
				rig.prevPos  = nowPos

				local v_forward = v_phys
				if rig.isLocal then
					-- 3) 输入意图（仅本地兜底）
					local hum = character:FindFirstChildOfClass("Humanoid")
					local v_intent = 0
					if hum then v_intent = hum.MoveDirection:Dot(forward) * (hum.WalkSpeed or 0) end
					local a, b, c = math.abs(v_phys), math.abs(v_pos), math.abs(v_intent)
					v_forward = v_phys
					if b > a and b >= c then v_forward = v_pos end
					if c > math.max(a, b) then v_forward = v_intent end
				else
					-- 非本地：只在物理/位移之间择优
					if math.abs(v_pos) > math.abs(v_phys) then v_forward = v_pos end
				end

				local speedMag = math.abs(v_forward)
				if (not rig.moving and speedMag > SPEED_ON) or (rig.moving and speedMag < SPEED_OFF) then
					rig.moving = speedMag > SPEED_ON
				end

				rig.v_forward = v_forward
			end
		end
	end
end)

-- ===== Render：写旋转（直接归零）=====
UpdatorManager:RenderStepped(function(dt)
	for _, rig in pairs(rigs) do
		if rig and rig.handle and rig.handle.Parent then
			local v_forward = rig.v_forward or 0
			for _, w in ipairs(rig.wheels) do
				-- 当角色移动 或 正在游戏/训练时，车轮转动
				if (rig.moving or IsInGame or IsInTraining) and w.radius > R_MIN then
					local speed = math.abs(v_forward)
					-- 若静止但处于游戏/训练状态，给一个默认视觉角速度
					if speed < 1e-3 and (IsInGame or IsInTraining) then
						speed = 8.0 -- 可调，越大转越快，仅视觉用途
					end
					w.angVel = clampOmega(DIR * speed / w.radius)
				else
					w.angVel = 0
				end

				w.theta += w.angVel * dt
				w.motor.C0 = w.baseC0 * CFrame.fromAxisAngle(AXIS, w.theta)
			end
		end
	end
end)
