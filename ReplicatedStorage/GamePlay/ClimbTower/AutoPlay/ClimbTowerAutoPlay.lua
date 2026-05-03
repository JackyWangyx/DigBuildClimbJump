local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService") -- 【新增】引入动作服务

local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local SceneAreaManager = require(game.ReplicatedStorage.ScriptAlias.SceneAreaManager)
local BuildingManager = require(game.ReplicatedStorage.ScriptAlias.BuildingManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local UIIndexManager = require(game.ReplicatedStorage.ScriptAlias.UIIndexManager)

local ClimbTowerGameLoop = nil
local ClimbTowerGameManager = nil
local ClimbTowerDefine = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerDefine)

local Define = require(game.ReplicatedStorage.Define)

local ClimbTowerAutoPlay = {}

-- 【修改】处理自动爬塔期间的强制跳跃
local function OnAutoClimbJump(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		-- 1. 必须【先】主动结束 AutoClimb 状态！
		-- 这会调用 control:Enable()，让角色重新能够接收物理指令
		ClimbTowerAutoPlay:EndAutoClimb()

		-- 2. 稍微等一帧，确保 Roblox 的控制模块已经完全苏醒
		task.wait()

		local player = game.Players.LocalPlayer
		local humanoid = PlayerManager:GetHumanoid(player)
		if humanoid then
			-- 3. 双保险：发送跳跃指令 + 强制把状态踢出攀爬！
			humanoid.Jump = true 
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end

ClimbTowerAutoPlay.Info = {
	IsAutoGame = false,
	IsAutoClimb = false,
	IsAutoDig = false,
	IsAutoClick = false,
}

function ClimbTowerAutoPlay:Init()
	ClimbTowerGameLoop = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameLoop)
	ClimbTowerGameManager = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameManager)
	ClimbTowerAutoPlay.Info.IsAutoGame = false

	task.spawn(function()
		ClimbTowerAutoPlay:UpdateAutoPlay()
	end)
end

function ClimbTowerAutoPlay:GetTower()
	local areaInfo = SceneAreaManager.AreaInfoList[ClimbTowerGameLoop.GameInitParam.TowerIndex]
	local tower = areaInfo.Area.Game.Tower
	return tower
end

local lastTime = 0

function ClimbTowerAutoPlay:UpdateAutoPlay()
	task.wait()
	lastTime = tick()

	while true do
		local success, result = pcall(function()
			ClimbTowerAutoPlay:UpdateImpl()
		end)
		
		if not success then
			ClimbTowerAutoPlay:EndAll()
		end
	end
end

function ClimbTowerAutoPlay:UpdateImpl()
	local player = game.Players.LocalPlayer
	
	local currentPhase = ClimbTowerGameLoop.GamePhase
	local currentTime = tick()
	local deltaTime = currentTime - lastTime

	-- ============================================================
	-- 【逻辑 1：自动游戏 (Auto Game) - 全自动循环模式】
	-- ============================================================
	if ClimbTowerAutoPlay.Info.IsAutoGame then
		if currentPhase == ClimbTowerDefine.GamePhase.Idle then
			-- 1. 落地复位阶段
			task.wait(1)

			local areaInfo = SceneAreaManager.AreaInfoList[ClimbTowerGameLoop.GameInitParam.TowerIndex]
			local startPosPart = areaInfo.Area.Game.ClimbStartPos

			-- 【关键修复】：手动重置标记，防止逻辑判定已登顶
			if ClimbTowerGameLoop.UpdateInfo then
				ClimbTowerGameLoop.UpdateInfo.IsClimbComplete = false
			end

			-- 传送：直接对齐坐标和朝向
			local rootPart = PlayerManager:GetHumanoidRootPart(player)
			if rootPart then
				rootPart.CFrame = startPosPart.CFrame
			end

			-- 【关键修复】：手动触发开始，不再等物理碰撞感应
			local gameManager = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameManager)
			gameManager:Enter(ClimbTowerGameLoop.GameInitParam.TowerIndex)

			task.wait(0.1)

		elseif currentPhase == ClimbTowerDefine.GamePhase.Up then
			-- 2. 上升阶段
			local humanoid = PlayerManager:GetHumanoid(player)
			local areaInfo = SceneAreaManager.AreaInfoList[ClimbTowerGameLoop.GameInitParam.TowerIndex]
			local topPart = areaInfo.Area.Game.Tower.Top

			-- 【关键修复】：改用 MoveTo，它能对抗激活窗口时官方控制脚本产生的“零输入”干扰
			-- 同时移除了对 state == Climbing 的硬性判断，强制执行移动
			if humanoid and not ClimbTowerGameLoop.UpdateInfo.IsClimbComplete then
				--humanoid:MoveTo(topPart.Position)
				humanoid:Move(Vector3.new(0, 0, -1), true)
			end

			-- 判定登顶
			if ClimbTowerGameLoop:CheckClimbComplete() then
				if ClimbTowerGameLoop:CheckClimbTop() then
					ClimbTowerGameManager:GetWins()
				end

				-- 停止移动
				PlayerManager:ClearMove(player)
				humanoid:MoveTo(PlayerManager:GetHumanoidRootPart(player).Position)

				-- 触发下落流程
				ClimbTowerGameLoop:EnterDown()	
				task.wait(0.5)
			end

		elseif currentPhase == ClimbTowerDefine.GamePhase.Down then
			-- 3. 下落阶段：静静等待落地，不执行任何指令
			task.wait(0.1)
		end

		-- ============================================================
		-- 【逻辑 2：自动爬 (Auto Climb) - 辅助攀爬模式】
		-- ============================================================
	elseif ClimbTowerAutoPlay.Info.IsAutoClimb and not ClimbTowerAutoPlay.Info.IsAutoGame then
		if currentPhase == ClimbTowerDefine.GamePhase.Up then
			local humanoid = PlayerManager:GetHumanoid(player)

			-- 实时动态高度检测
			local isComplete = ClimbTowerGameLoop.UpdateInfo.IsClimbComplete or ClimbTowerGameLoop:CheckClimbComplete()

			-- 核心逻辑：只要没判定登顶，就持续向上推
			if not isComplete then
				-- 辅助模式下保留 Move 即可，让玩家能微调方向
				humanoid:Move(Vector3.new(0, 0, -1), true)
			else
				-- 【新增逻辑：登顶后往 Top 中心安全移动一段距离】
				local areaInfo = SceneAreaManager.AreaInfoList[ClimbTowerGameLoop.GameInitParam.TowerIndex]
				local topPart = areaInfo.Area.Game.Tower.Top
				local rootPart = PlayerManager:GetHumanoidRootPart(player)

				if topPart and rootPart then
					-- 1. 计算从玩家当前位置指向 Top 中心的水平向量（忽略 Y 轴高度差）
					local targetPos = Vector3.new(topPart.Position.X, rootPart.Position.Y, topPart.Position.Z)
					local moveDir = (targetPos - rootPart.Position).Unit

					-- 2. 强制往中心方向走 15 帧（大约 0.3 秒，确保站稳且绝对不会偏离掉下）
					-- 注意这里的第二个参数改成了 false，代表 moveDir 是世界坐标系下的绝对方向
					for i = 1, 30 do
						humanoid:Move(moveDir, false)
						task.wait()
					end
				end

				-- 3. 走完安全距离后，彻底刹车并结束 AutoClimb
				PlayerManager:ClearMove(player)
				humanoid:Move(Vector3.new(0, 0, 0), true)
				ClimbTowerAutoPlay:EndAutoClimb()
				return
			end

		elseif currentPhase == ClimbTowerDefine.GamePhase.Idle or currentPhase == ClimbTowerDefine.GamePhase.Down then
			-- 如果是因为手动跳下或意外回地，关闭辅助
			ClimbTowerAutoPlay:EndAutoClimb()
		end

	elseif ClimbTowerAutoPlay.Info.IsAutoDig then
		-- 自动挖掘占位
		task.wait(0.1)
	else
		-- 无事可做时的待机
		task.wait(0.1)
	end

	task.wait()
	lastTime = currentTime
end

function ClimbTowerAutoPlay:CheckClimbNearTop(deltaTime)
	local player = game.Players.LocalPlayer
	local humanoid = PlayerManager:GetHumanoid(player)
	local topHeight = ClimbTowerGameLoop:GetTowerLength() + ClimbTowerDefine.Game.AutoClimbStopTopOffset
	local playerHeight = PlayerManager:GetHeight(player) + humanoid.WalkSpeed * deltaTime
	return playerHeight >= topHeight
end

function ClimbTowerAutoPlay:EndAll()
	ClimbTowerAutoPlay:EndAutoGame()
	ClimbTowerAutoPlay:EndAutoClimb()
	ClimbTowerAutoPlay:EndAutoDig()
	ClimbTowerAutoPlay:EndAutoClick()
end

-- Auto Game

function ClimbTowerAutoPlay:StartAutoGame()
	if ClimbTowerAutoPlay.Info.IsAutoGame then return end
	ClimbTowerAutoPlay.Info.IsAutoGame = true
	EventManager:Dispatch(EventManager.Define.RefreshAutoPlay, ClimbTowerAutoPlay.Info)

	local player = game.Players.LocalPlayer
	local control = PlayerManager:GetControl(player)
	control:Disable()
end

function ClimbTowerAutoPlay:EndAutoGame()
	if not ClimbTowerAutoPlay.Info.IsAutoGame then return end
	ClimbTowerAutoPlay.Info.IsAutoGame = false
	EventManager:Dispatch(EventManager.Define.RefreshAutoPlay, ClimbTowerAutoPlay.Info)

	local player = game.Players.LocalPlayer
	local control = PlayerManager:GetControl(player)
	control:Enable()
end

-- Auto Climb

function ClimbTowerAutoPlay:StartAutoClimb()
	if ClimbTowerAutoPlay.Info.IsAutoClimb then return end
	ClimbTowerAutoPlay.Info.IsAutoClimb = true
	EventManager:Dispatch(EventManager.Define.RefreshAutoPlay, ClimbTowerAutoPlay.Info)


	local player = game.Players.LocalPlayer
	local control = PlayerManager:GetControl(player)
	control:Disable()

	-- 【新增】：绑定临时的跳跃按键 (兼容PC的空格键)
	-- 第三个参数 true 代表：如果是手机端，会在屏幕右下角自动生成一个虚拟按钮！
	ContextActionService:BindAction("AutoClimbJump", OnAutoClimbJump, true, Enum.KeyCode.Space)
	ContextActionService:SetTitle("AutoClimbJump", "跳下") 
	ContextActionService:SetPosition("AutoClimbJump", UDim2.new(1, -120, 1, -120))
end

function ClimbTowerAutoPlay:EndAutoClimb()
	if not ClimbTowerAutoPlay.Info.IsAutoClimb then return end
	ClimbTowerAutoPlay.Info.IsAutoClimb = false
	EventManager:Dispatch(EventManager.Define.RefreshAutoPlay, ClimbTowerAutoPlay.Info)

	local player = game.Players.LocalPlayer
	local control = PlayerManager:GetControl(player)
	control:Enable()

	-- 【新增】：结束自动爬时，解绑临时跳跃键（手机上的虚拟按钮也会自动消失）
	ContextActionService:UnbindAction("AutoClimbJump")
end

-- Auto Dig

function ClimbTowerAutoPlay:StartAutoDig()
	if ClimbTowerAutoPlay.Info.IsAutoDig then return end
	ClimbTowerAutoPlay.Info.IsAutoDig = true
	EventManager:Dispatch(EventManager.Define.RefreshAutoPlay, ClimbTowerAutoPlay.Info)
end

function ClimbTowerAutoPlay:EndAutoDig()
	if not ClimbTowerAutoPlay.Info.IsAutoDig then return end
	ClimbTowerAutoPlay.Info.IsAutoDig = false
	EventManager:Dispatch(EventManager.Define.RefreshAutoPlay, ClimbTowerAutoPlay.Info)
end

-- Click

function ClimbTowerAutoPlay:StartAutoClick()
	if ClimbTowerAutoPlay.Info.IsAutoClick then	return end
	ClimbTowerAutoPlay.Info.IsAutoClick = true
	EventManager:Dispatch(EventManager.Define.RefreshAutoPlay, ClimbTowerAutoPlay.Info)
end

function ClimbTowerAutoPlay:EndAutoClick()
	if not ClimbTowerAutoPlay.Info.IsAutoClick then	return end
	ClimbTowerAutoPlay.Info.IsAutoClick = false
	EventManager:Dispatch(EventManager.Define.RefreshAutoPlay, ClimbTowerAutoPlay.Info)
end

return ClimbTowerAutoPlay