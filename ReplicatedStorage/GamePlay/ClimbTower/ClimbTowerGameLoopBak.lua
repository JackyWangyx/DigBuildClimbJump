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
	local top = areaInfo.Area.Game.Tower.Top
	local height = top.Position.Y
	return height
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
	--warn(newState, ClimbTowerGameLoop.GamePhase)
	if ClimbTowerGameLoop.GamePhase == ClimbTowerDefine.GamePhase.Idle then 
		if newState == Enum.HumanoidStateType.Climbing then
			-- 进入游戏，攀爬
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
		if newState == Enum.HumanoidStateType.Freefall then
			if not ClimbTowerGameLoop.UpdateInfo.IsClimbComplete then
				-- 攀爬过程中主动跳落
				local gameManager = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameManager)
				gameManager:Slide()
				PlayerManager:ClearMove(player)

				PlayerManager:DisableClimb(player)
				
				--warn("Slide 2")
			else
				-- 到顶部跳落
				local distance = ClimbTowerGameLoop:GetPlayerDistance()
				if distance < ClimbTowerGameLoop:GetTowerLength() then
					local gameManager = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameManager)
					gameManager:Slide()
					PlayerManager:ClearMove(player)

					PlayerManager:DisableClimb(player)
					
					--warn("Slide 1")
				end
			end	
		elseif newState == Enum.HumanoidStateType.Running then
			-- 攀爬过程中切换到跑步状态
			local distance = ClimbTowerGameLoop:GetPlayerDistance()
			if distance < ClimbTowerDefine.Game.LandedCheckHeight then
				-- 向下爬回地面
				local gameManager = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameManager)
				gameManager:Exit()
				
				PlayerManager:EnableClimb(player)
				
				--warn("Exit 2")
			elseif distance >= ClimbTowerGameLoop:GetTowerLength() and
				not ClimbTowerGameLoop.UpdateInfo.IsClimbComplete 
			then
				-- 爬到梯子顶端
				--local gameManager = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameManager)
				--gameManager:ArriveEnd()
				
				ClimbTowerGameLoop.UpdateInfo.IsClimbComplete = true		
				PlayerManager:ClearMove(player)
				local rootPart = PlayerManager:GetHumanoidRootPart(player)
				if rootPart then
					rootPart.Velocity = Vector3.new(0, 5, 0)
				end
				
				local humanoid = PlayerManager:GetHumanoid(player)
				humanoid.WalkSpeed = Define.Game.WalkSpeed
				
				--warn("Climb Complete")
			end
		end	
	elseif ClimbTowerGameLoop.GamePhase == ClimbTowerDefine.GamePhase.Down then	
		if newState == Enum.HumanoidStateType.Landed or
			newState == Enum.HumanoidStateType.Running
		then
			local distance = ClimbTowerGameLoop:GetPlayerDistance()
			if distance < ClimbTowerDefine.Game.LandedCheckHeight then
				-- 跳落 -> 落地
				PlayerManager:ClearMove(player)
				
				local gameManager = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameManager)
				gameManager:GetCoin()
				
				task.wait()
				
				gameManager:Exit()

				PlayerManager:EnableClimb(player)
				ClimbTowerGameLoop:DropEffect()
				
				--warn("Exit 1")
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
	ClimbTowerGameLoop.GamePhase = ClimbTowerDefine.GamePhase.ArriveEnd
	local updateInfo = ClimbTowerGameLoop.UpdateInfo
	
	if ClimbTowerAutoPlay.Info.IsAutoGame then
		task.wait(1)
		local player = game.Players.LocalPlayer
		local gameManager = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameManager)
		gameManager:GetWins(player)
		gameManager:Slide(player)	
	end
end

function ClimbTowerGameLoop:EnterDown()
	local player = game.Players.LocalPlayer
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
	
	if updateInfo.IsClimbComplete then
		-- 爬完梯子（无所谓是否到顶部平台）,后主动跳下
		local player = game.Players.LocalPlayer
		local state = PlayerManager:GetState(player)
		local distance = ClimbTowerGameLoop:GetPlayerDistance()
		if state == Enum.HumanoidStateType.Freefall and 
			distance < ClimbTowerGameLoop:GetTowerLength() then
			local gameManager = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameManager)
			gameManager:Slide()
			ClimbTowerGameLoop.GamePhase = ClimbTowerDefine.GamePhase.Busy
			
			PlayerManager:DisableClimb(player)

			--warn("Slide 1")
		end
	else
		updateInfo.MoveDistance = ClimbTowerGameLoop:GetPlayerDistance() 
		if updateInfo.MoveDistance > updateInfo.ArriveDistance then
			updateInfo.ArriveDistance = updateInfo.MoveDistance
		end
	end
end

function ClimbTowerGameLoop:UpdateDown(deltaTime)

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
