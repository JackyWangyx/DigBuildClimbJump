local RunService = game:GetService("RunService")

local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local SceneAreaManager = require(game.ReplicatedStorage.ScriptAlias.SceneAreaManager)
local BuildingManager = require(game.ReplicatedStorage.ScriptAlias.BuildingManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)

local ClimbTowerGameLoop = nil
local ClimbTowerGameManager = nil
local ClimbTowerDefine = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerDefine)

local Define = require(game.ReplicatedStorage.Define)

local ClimbTowerAutoPlay = {}

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
		ClimbTowerAutoPlay:AutoPlayCo()
	end)
end

function ClimbTowerAutoPlay:GetTower()
	local areaInfo = SceneAreaManager.AreaInfoList[ClimbTowerGameLoop.GameInitParam.TowerIndex]
	local tower = areaInfo.Area.Game.Tower
	return tower
end

function ClimbTowerAutoPlay:AutoPlayCo()
	task.wait()
	local player = game.Players.LocalPlayer
	
	while true do
		local currentPhase = ClimbTowerGameLoop.GamePhase
		if ClimbTowerAutoPlay.Info.IsAutoGame then
			if currentPhase == ClimbTowerDefine.GamePhase.Idle then
				-- 自动游戏
				task.wait(1)
				
				local areaInfo = SceneAreaManager.AreaInfoList[ClimbTowerGameLoop.GameInitParam.TowerIndex]
				local startPos = areaInfo.Area.Game.ClimbStartPos
				PlayerManager:SetCFrameToPart(player, startPos)
				
				task.wait()
			elseif currentPhase == ClimbTowerDefine.GamePhase.Up then
				local state = PlayerManager:GetState(player)
				if state == Enum.HumanoidStateType.Climbing then
					local humanoid = PlayerManager:GetHumanoid(player)
					humanoid:Move(Vector3.new(0, 1, 0), false)
				end
				
				if ClimbTowerGameLoop:CheckClimbComplete() then
					if ClimbTowerGameLoop:CheckClimbTop() then
						ClimbTowerGameManager:GetWins()
					end

					ClimbTowerGameLoop:EnterDown()
				end
			elseif currentPhase == ClimbTowerDefine.GamePhase.Down then

			end
		elseif ClimbTowerAutoPlay.Info.IsAutoClimb and not ClimbTowerAutoPlay.Info.IsAutoGame then
			-- 自动爬
			if currentPhase == ClimbTowerDefine.GamePhase.Up then
				local state = PlayerManager:GetState(player)
				if state == Enum.HumanoidStateType.Climbing then
					local humanoid = PlayerManager:GetHumanoid(player)
					humanoid:Move(Vector3.new(0, 1, 0), false)
				end
				
				if ClimbTowerGameLoop:CheckClimbComplete() then
					if ClimbTowerGameLoop:CheckClimbTop() then
						ClimbTowerGameManager:GetWins()
					end
					
					ClimbTowerGameLoop:ManualSlide()				
					ClimbTowerAutoPlay:EndAutoClimb()
				end
			end
		elseif ClimbTowerAutoPlay.Info.IsAutoDig then
			-- 自动挖掘
			
		end
		
		task.wait(0.1)
	end
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
end

function ClimbTowerAutoPlay:EndAutoClimb()
	if not ClimbTowerAutoPlay.Info.IsAutoClimb then return end
	ClimbTowerAutoPlay.Info.IsAutoClimb = false
	EventManager:Dispatch(EventManager.Define.RefreshAutoPlay, ClimbTowerAutoPlay.Info)

	local player = game.Players.LocalPlayer
	local control = PlayerManager:GetControl(player)
	control:Enable()
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
