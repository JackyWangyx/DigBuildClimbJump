local SceneManager = require(game.ReplicatedStorage.ScriptAlias.SceneManager)
local SceneAreaManager = require(game.ReplicatedStorage.ScriptAlias.SceneAreaManager)
local ResourcesManager = require(game.ReplicatedStorage.ScriptAlias.ResourcesManager)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local UpdateManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local UTween = require(game.ReplicatedStorage.ScriptAlias.UTween)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local CameraManager = require(game.ReplicatedStorage.ScriptAlias.CameraManager)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
--local PlayerMove = require(game.ReplicatedStorage.ScriptAlias.PlayerMove)

local ClimbTowerDefine = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerDefine)
local ClimbTowerAutoPlay = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerAutoPlay)

local Define = require(game.ReplicatedStorage.Define)

local ClimbTowerGameLoop = {}

ClimbTowerGameLoop.GamePhase = ClimbTowerDefine.GamePhase.Idle
ClimbTowerGameLoop.TowerIndex = -1

ClimbTowerGameLoop.GameInitParam = nil
ClimbTowerGameLoop.UpdateInfo = {}
ClimbTowerGameLoop.IsCompleteGame = false

function ClimbTowerGameLoop:Init()
	UpdateManager:RenderStepped(function(deltaTime)
		ClimbTowerGameLoop:Update(deltaTime)
	end)

	local player = game.Players.LocalPlayer
	PlayerManager:HandleStateChanged(player, function(oldState, newState)
		ClimbTowerGameLoop:OnStateChanged(player, oldState, newState)
	end)

	EventManager:Listen(ClimbTowerDefine.Event.Enter, function(gameInitParam)
		ClimbTowerGameLoop.GameInitParam = gameInitParam
		ClimbTowerGameLoop:EnterUp()

		--local areaInfo = SceneAreaManager.AreaInfoList[ClimbTowerGameLoop.GameInitParam.TowerIndex]
	end)

	EventManager:Listen(ClimbTowerDefine.Event.ArriveEnd, function()
		ClimbTowerGameLoop:EnterTop()

		--task.delay(ClimbTowerDefine.Game.DropEffectDelay, function()
		--	local areaInfo = SceneAreaManager.AreaInfoList[ClimbTowerGameLoop.GameInitParam.TowerIndex]
		--end)	
	end)

	EventManager:Listen(ClimbTowerDefine.Event.Slide, function()
		ClimbTowerGameLoop:EnterDown()
	end)

	EventManager:Listen(ClimbTowerDefine.Event.Exit, function()
		ClimbTowerGameLoop:EnterFinish()

		--task.delay(ClimbTowerDefine.Game.DropEffectDelay, function()
		--	local areaInfo = SceneAreaManager.AreaInfoList[ClimbTowerGameLoop.GameInitParam.TowerIndex]
		--end)	
	end)

	EventManager:Listen(ClimbTowerDefine.Event.Reset, function()
		SceneAreaManager:ResetPlayerPos(game.Players.LocalPlayer)
	end)

	EventManager:Listen(ClimbTowerDefine.Event.LogGameProperty, function()
		ClimbTowerGameLoop:LogGameProperty()
	end)
end

function ClimbTowerGameLoop:LogGameProperty()
	warn(ClimbTowerGameLoop.GameInitParam, ClimbTowerGameLoop.UpdateInfo)
end

function ClimbTowerGameLoop:GetPlayerDistance()
	local player = game.Players.LocalPlayer
	local height = PlayerManager:GetHeight(player)
	local distance = height + ClimbTowerDefine.Game.GroundHeightOffset
	return distance
end

function ClimbTowerGameLoop:GetTowerLength()
	local areaInfo = SceneAreaManager.AreaInfoList[ClimbTowerGameLoop.GameInitParam.TowerIndex]
	local tower = areaInfo.Area.Game.Tower
	local top = tower.Top
	local height = top.Position.Y
	return height
end

function ClimbTowerGameLoop:GetTowerMaxLength()
	local areaInfo = SceneAreaManager.AreaInfoList[ClimbTowerGameLoop.GameInitParam.TowerIndex]
	local tower = areaInfo.Area.Game.Tower
	local top = tower.Top
	local root = tower.Root
	local length = top.Position.Y - root.Postiton.Y
	return length
end

function ClimbTowerGameLoop:GetClimbingPart()
	local player = game.Players.LocalPlayer
	local humanoid = PlayerManager:GetHumanoid(player)
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	if not humanoid or not rootPart then return nil end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { player.Character }
	params.RespectCanCollide = true
	params.IgnoreWater = true

	-- 使用 Blockcast（推荐）
	local cast = game.Workspace:Blockcast(
		rootPart.CFrame,
		Vector3.new(0.1, 2, 0),  -- 细长 Block
		rootPart.CFrame.LookVector * 2,  -- 向前 2 studs
		params
	)

	if cast and cast.Instance:IsA("TrussPart") then
		return cast.Instance  -- 返回 Truss
	end

	return nil
end

function ClimbTowerGameLoop:GetAreaIndex(startInstance: Instance): number?
	local current: Instance? = startInstance

	while current do
		local name = current.Name
		if name:sub(1,5) == "Area_" then
			local num = tonumber(name:sub(6))
			if num then
				return num
			end
		end
		current = current.Parent
	end

	return -1
end

function ClimbTowerGameLoop:CheckClimbComplete()
	local distance = ClimbTowerGameLoop:GetPlayerDistance()
	if distance > ClimbTowerGameLoop:GetTowerLength() then
		return true
	end

	return false
end

function ClimbTowerGameLoop:CheckClimbTop()
	return ClimbTowerGameLoop:CheckClimbComplete() and ClimbTowerGameLoop.GameInitParam.IsTowerMaxLevel
end

function ClimbTowerGameLoop:OnStateChanged(player, oldState, newState)	
	if ClimbTowerGameLoop.GamePhase == ClimbTowerDefine.GamePhase.Idle then 
		if newState == Enum.HumanoidStateType.Climbing then
			local currentTruss = ClimbTowerGameLoop:GetClimbingPart()
			if currentTruss then
				local currentAreaIndex = ClimbTowerGameLoop:GetAreaIndex(currentTruss)
				if currentAreaIndex > 0 then
					local gameManager = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameManager)
					gameManager:Enter(currentAreaIndex)
				end
			end
		end
	elseif ClimbTowerGameLoop.GamePhase == ClimbTowerDefine.GamePhase.Up then
		-- 上升阶段，攀爬中
		if newState == Enum.HumanoidStateType.Running then
			-- 攀爬过程中切换到跑步状态
			local distance = ClimbTowerGameLoop:GetPlayerDistance()
			if distance < ClimbTowerDefine.Game.LandedCheckHeight then
				-- 向下爬回地面
				local gameManager = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameManager)
				gameManager:Exit()
				PlayerManager:EnableClimb(player)
			end
			-- 【删除】：把这里原本长长的一串登顶判断（distance >= ClimbTowerGameLoop:GetTowerLength()）全部删掉！
		end	
	elseif ClimbTowerGameLoop.GamePhase == ClimbTowerDefine.GamePhase.Down then	
		if newState == Enum.HumanoidStateType.Landed or
			newState == Enum.HumanoidStateType.Running
		then
			local distance = ClimbTowerGameLoop:GetPlayerDistance()
			if distance <= ClimbTowerDefine.Game.LandedCheckHeight + 1 then
				local rootPart = PlayerManager:GetHumanoidRootPart(player)
				if rootPart then
					rootPart.AssemblyLinearVelocity = Vector3.zero
					rootPart.AssemblyAngularVelocity = Vector3.zero
				end

				local humanoid = PlayerManager:GetHumanoid(player)
				if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Landed then
					humanoid:ChangeState(Enum.HumanoidStateType.Landed)
				end

				PlayerManager:ClearMove(player)
				local gameManager = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameManager)
				gameManager:GetCoin()
				task.wait()
				gameManager:Exit()

				PlayerManager:EnableClimb(player)
				ClimbTowerGameLoop:DropEffect()
			end
		end
	end
end

---------------------------------------------------------------------------------------------------------
-- Phase

function ClimbTowerGameLoop:EnterUp()
	ClimbTowerGameLoop.GamePhase = ClimbTowerDefine.GamePhase.Up
	local gameInitParam = ClimbTowerGameLoop.GameInitParam
	ClimbTowerGameLoop.IsCompleteGame = false

	local uiGameInfo = require(game.ReplicatedStorage.ScriptAlias.UIClimbTowerGameInfo)
	uiGameInfo:ShowClimbButtons()

	-- Create Tower
	ClimbTowerGameLoop.TowerIndex = gameInitParam.TowerIndex

	local towerRoot = SceneManager.AreaList[ClimbTowerGameLoop.TowerIndex]

	-- Init Status
	local player = game.Players.LocalPlayer
	local rootPart = PlayerManager:GetHumanoidRootPart(player)

	ClimbTowerGameLoop.UpdateInfo = {
		Player = player,
		RootPart = rootPart,
		MoveSpeed = gameInitParam.Speed,
		MoveDistance = 0,
		ArriveDistance = 0,
		MoveAcceleration = 0,
		IsClimbComplete = false,
	}
end

function ClimbTowerGameLoop:EnterTop()
	--ClimbTowerGameLoop.GamePhase = ClimbTowerDefine.GamePhase.ArriveEnd
	--local updateInfo = ClimbTowerGameLoop.UpdateInfo

	--if ClimbTowerAutoPlay.Info.IsAutoGame then
	--	task.wait(1)
	--	local player = game.Players.LocalPlayer
	--	local gameManager = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameManager)
	--	gameManager:GetWins(player)
	--	gameManager:Slide(player)	
	--end
end

function ClimbTowerGameLoop:EnterDown()
	local player = game.Players.LocalPlayer
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	local updateInfo = ClimbTowerGameLoop.UpdateInfo

	if ClimbTowerGameLoop.GamePhase == ClimbTowerDefine.GamePhase.ArriveEnd then

	end

	local state = PlayerManager:GetState(player)
	if state == Enum.HumanoidStateType.Climbing then
		ClimbTowerGameLoop:ManualSlide()
	end

	ClimbTowerGameLoop.GamePhase = ClimbTowerDefine.GamePhase.Down
	local updateInfo = ClimbTowerGameLoop.UpdateInfo
	updateInfo.MoveSpeed = 0
	updateInfo.MoveDistance = ClimbTowerGameLoop:GetPlayerDistance()

	-- 【新增】：记录下落时间，用于计算渐进式重力
	updateInfo.FallTime = 0

	-- 【核心修复】：利用 Top 部件计算绝对向外的下落点
	if rootPart then
		local areaInfo = SceneAreaManager.AreaInfoList[ClimbTowerGameLoop.GameInitParam.TowerIndex]
		local topPart = areaInfo.Area.Game.Tower.Top

		if topPart then
			-- 1. 计算水平向外的向量
			local towerPos = Vector2.new(topPart.Position.X, topPart.Position.Z)
			local playerPos = Vector2.new(rootPart.Position.X, rootPart.Position.Z)
			local awayDir2D = (playerPos - towerPos).Unit
			if playerPos == towerPos then awayDir2D = Vector2.new(0, 1) end

			local awayDir = Vector3.new(awayDir2D.X, 0, awayDir2D.Y)

			-- 2. 计算 10 Studs 外的目标点
			local dropOffset = 5 
			local targetDropPos = rootPart.Position + (awayDir * dropOffset)

			-- 3. 【核心新增】：计算“面朝外”的旋转
			local targetRotation = CFrame.lookAt(Vector3.zero, awayDir).Rotation

			-- 4. 存入 updateInfo，锁定位置和旋转
			updateInfo.FixedDropX = targetDropPos.X
			updateInfo.FixedDropZ = targetDropPos.Z
			updateInfo.FixedRotation = targetRotation 

			-- 5. 瞬间对齐：位置移到轨道，朝向转到外面
			rootPart.CFrame = CFrame.new(targetDropPos.X, rootPart.Position.Y, targetDropPos.Z) * targetRotation
		end
	end

	-- 【核心新增】：进入下落阶段，立刻剥夺玩家的方向键控制权
	local control = PlayerManager:GetControl(player)
	if control then
		control:Disable()
	end

	-- ▼▼▼ 就在这里！【防躺地修复】：彻底禁用下落时的绊倒和布娃娃状态 ▼▼▼
	local humanoid = PlayerManager:GetHumanoid(player)
	if humanoid then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	end
end

function ClimbTowerGameLoop:ManualSlide()
	local player = game.Players.LocalPlayer
	local humanoid = PlayerManager:GetHumanoid(player)
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	PlayerManager:ClearMove(player)
	PlayerManager:DisableClimb(player)

	local lookVector = rootPart.CFrame.LookVector
	local backDir = Vector3.new(-lookVector.X, 0, -lookVector.Z).Unit  -- 水平向后

	local jumpVelocity = backDir * 50 + Vector3.new(0, 50, 0)
	rootPart.AssemblyLinearVelocity = rootPart.AssemblyLinearVelocity + jumpVelocity

	humanoid.Jump = true

	task.spawn(function()
		task.wait(0.2)
		PlayerManager:EnableClimb(player)
	end)
end

function ClimbTowerGameLoop:EnterFinish()
	ClimbTowerGameLoop.GamePhase = ClimbTowerDefine.GamePhase.Idle

	local player = game.Players.LocalPlayer
	local control = PlayerManager:GetControl(player)
	if control then
		control:Enable()
	end

	-- 【恢复状态】：恢复跌倒状态，以免影响游戏其他机制
	local humanoid = PlayerManager:GetHumanoid(player)
	if humanoid then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
	end
end
---------------------------------------------------------------------------------------------------------
-- Update

function ClimbTowerGameLoop:Update(deltaTime)
	if ClimbTowerGameLoop.GamePhase == ClimbTowerDefine.GamePhase.Up then
		ClimbTowerGameLoop:UpdateUp(deltaTime)
	elseif ClimbTowerGameLoop.GamePhase == ClimbTowerDefine.GamePhase.Down then
		ClimbTowerGameLoop:UpdateDown(deltaTime)
	end
end

function ClimbTowerGameLoop:UpdateUp(deltaTime)
	local updateInfo = ClimbTowerGameLoop.UpdateInfo
	local player = game.Players.LocalPlayer
	local state = PlayerManager:GetState(player)
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	local isFallingDown = false

	if state == Enum.HumanoidStateType.Freefall and rootPart then
		if rootPart.AssemblyLinearVelocity.Y < -10 then
			isFallingDown = true
		end
	end

	local distance = ClimbTowerGameLoop:GetPlayerDistance()
	local towerLength = ClimbTowerGameLoop:GetTowerLength()

	-- 【新增核心】：实时高度截断！
	-- 只要高度达标，且还没判定登顶，瞬间强制登顶
	if not updateInfo.IsClimbComplete and distance >= towerLength then
		updateInfo.IsClimbComplete = true

		local uiGameInfo = require(game.ReplicatedStorage.ScriptAlias.UIClimbTowerGameInfo)
		uiGameInfo:HideClimbButtons()

		PlayerManager:ClearMove(player)

		if rootPart then
			-- 【关键修复】：保留X和Z方向的动能(让玩家顺势翻越平台)，
			-- 但把Y轴(向上)那巨大的飞天惯性强行压低到 5，稳稳落地！
			local currentVel = rootPart.AssemblyLinearVelocity
			rootPart.AssemblyLinearVelocity = Vector3.new(currentVel.X, 5, currentVel.Z)
		end

		local humanoid = PlayerManager:GetHumanoid(player)
		if humanoid then
			humanoid.WalkSpeed = Define.Game.WalkSpeed
			-- 瞬间强制改变状态，不再等系统慢吞吞的判定
			humanoid:ChangeState(Enum.HumanoidStateType.Running)
		end
	end

	-- 原本的逻辑往下继续
	if updateInfo.IsClimbComplete then
		-- 登顶后，在平台上主动跳下
		if isFallingDown and distance < towerLength - 2 then
			local gameManager = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameManager)
			gameManager:Slide()
			ClimbTowerGameLoop.GamePhase = ClimbTowerDefine.GamePhase.Busy

			PlayerManager:DisableClimb(player)
		end
	else
		-- 还没登顶时的跳落判定（带有3 Studs的安全盲区）
		if isFallingDown and distance < (towerLength - 3) then
			local gameManager = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameManager)
			gameManager:Slide()
			PlayerManager:ClearMove(player)
			PlayerManager:DisableClimb(player)
		else
			-- 正常记录最高点
			updateInfo.MoveDistance = distance 
			if updateInfo.MoveDistance > updateInfo.ArriveDistance then
				updateInfo.ArriveDistance = updateInfo.MoveDistance
			end
		end
	end
end

function ClimbTowerGameLoop:UpdateDown(deltaTime)
	local player = game.Players.LocalPlayer
	local state = PlayerManager:GetState(player)
	local humanoid = PlayerManager:GetHumanoid(player)
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	local updateInfo = ClimbTowerGameLoop.UpdateInfo

	if not rootPart or not humanoid then return end

	local distance = ClimbTowerGameLoop:GetPlayerDistance()
	local currentVelocityY = rootPart.AssemblyLinearVelocity.Y

	if state == Enum.HumanoidStateType.Freefall then
		-- 【修改】：优化碰撞预测，消除半空发奖的现象
		local fallDistanceNextFrame = math.abs(currentVelocityY) * deltaTime

		-- 如果下一帧会穿模，或者距离地面已经极近
		if distance <= fallDistanceNextFrame or distance < 2 then
			-- 核心修复：直接把角色传送到贴地的绝对位置！
			-- 消除所有悬空感，让角色瞬间精确踩在地面上
			local targetY = rootPart.Position.Y - distance
			rootPart.CFrame = CFrame.new(rootPart.Position.X, targetY, rootPart.Position.Z) * rootPart.CFrame.Rotation

			-- 瞬间消除动能
			rootPart.AssemblyLinearVelocity = Vector3.zero
			rootPart.AssemblyAngularVelocity = Vector3.zero

			-- 强制切换到落地状态
			humanoid:ChangeState(Enum.HumanoidStateType.Landed)
			return
		end

		-- 渐进式重力计算
		updateInfo.FallTime = (updateInfo.FallTime or 0) + deltaTime
		local startGravity = 0
		local gravityIncreaseRate = 400
		local maxExtraGravity = 2000

		local currentExtraGravity = math.min(maxExtraGravity, startGravity + (gravityIncreaseRate * updateInfo.FallTime))
		local extraDropVelocity = Vector3.new(0, -currentExtraGravity * deltaTime, 0)
		local newVelocity = rootPart.AssemblyLinearVelocity + extraDropVelocity

		-- 终端速度限制
		local maxFallSpeed = -5000 
		if newVelocity.Y < maxFallSpeed then
			newVelocity = Vector3.new(newVelocity.X, maxFallSpeed, newVelocity.Z)
		end

		rootPart.AssemblyLinearVelocity = newVelocity
	end
end

---------------------------------------------------------------------------------------------------------
-- Effect

function ClimbTowerGameLoop:DropEffect()
	local player = game.Players.LocalPlayer
	local rootPart = PlayerManager:GetHumanoidRootPart(player)

	--local fxPrefab = ResourcesManager:Load("Fx/Fx_PlayerDrop")
	--Util:SpawnFxEmit(fxPrefab, rootPart.CFrame.Position, 20, 2)

	rootPart.AssemblyLinearVelocity = Vector3.zero
	rootPart.AssemblyAngularVelocity = Vector3.zero

	CameraManager:ShakeCamera()
end

return ClimbTowerGameLoop
