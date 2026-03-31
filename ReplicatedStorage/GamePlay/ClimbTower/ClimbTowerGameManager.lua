local SceneManager = require(game.ReplicatedStorage.ScriptAlias.SceneManager)
local ResourcesManager = require(game.ReplicatedStorage.ScriptAlias.ResourcesManager)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local ClickGame = require(game.ReplicatedStorage.ScriptAlias.ClickGame)
local SpeedLineEffect = require(game.ReplicatedStorage.ScriptAlias.SpeedLineEffect)
local TerrainManager = require(game.ReplicatedStorage.ScriptAlias.TerrainManager)
local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local PlayerAnimation = require(game.ReplicatedStorage.ScriptAlias.PlayerAnimation)
local CameraManager = require(game.ReplicatedStorage.ScriptAlias.CameraManager)
local SceneAreaManager = require(game.ReplicatedStorage.ScriptAlias.SceneAreaManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local SoundManager = require(game.ReplicatedStorage.ScriptAlias.SoundManager)

local DigAreaRewardManager = require(game.ReplicatedStorage.ScriptAlias.DigAreaRewardManager)
local ClimbTowerGameLoop = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameLoop)
local ClimbTowerAutoPlay = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerAutoPlay)
local StoneSplashEffect = require(game.ReplicatedStorage.ScriptAlias.StoneSplashEffect)

local ClimbTowerDefine = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerDefine)
local Define = require(game.ReplicatedStorage.Define)

local ClimbTowerGameManager = {}

ClimbTowerGameManager.GameRoot = nil
ClimbTowerGameManager.UpdateGameInfo = nil

function ClimbTowerGameManager:Init()
	ClimbTowerGameLoop:Init()
	ClimbTowerAutoPlay:Init()
	DigAreaRewardManager:Init()
	
	ClimbTowerGameManager:ResetDigArea()
	TerrainManager:InitDig(function()
		return ClimbTowerGameManager:CheckCanDig()
	end, function(success, hitPos)
		ClimbTowerGameManager:OnDigSuccess(success, hitPos)
	end, function()
		ClimbTowerGameManager:OnDigFail()
	end)
	
	UpdatorManager:Heartbeat(function(deltaTime)
		ClimbTowerGameManager:DigUpdate(deltaTime)
	end)
	
	ClickGame:Init()
	SpeedLineEffect:Init()
	
	ClimbTowerGameManager:RefreshData()
	
	EventManager:Listen(EventManager.Define.RefreshPower, function(value)
		ClimbTowerGameManager.CurrentPower = value
	end)
	
	EventManager:Listen(EventManager.Define.RefreshTool, function()
		ClimbTowerGameManager:RefreshData()
	end)
	
	local buildEffect = StoneSplashEffect.new()	
	EventManager:Listen(ClimbTowerDefine.Event.BuildTower, function()
		
		CameraManager:ShakeCamera(0.5, ClimbTowerDefine.Game.TowerUpgradeDuration)		
		SoundManager:PlaySFX(SoundManager.Define.BuildTower)
		
		local areaInfo = SceneAreaManager.AreaInfoList[SceneAreaManager.CurrentAreaIndex]
		local towerPos = areaInfo.Area.Game.TowerPos
		--local fxPrefab = ResourcesManager:Load(ClimbTowerDefine.Game.TowerUpgradeFx)
		--Util:SpawnFxEmit(fxPrefab, towerPos.Position, 20, 2)
		
		buildEffect:Start(towerPos.Position)
		task.wait(ClimbTowerDefine.Game.TowerUpgradeDuration)
		buildEffect:Stop()
	end)
	
	EventManager:Listen(EventManager.Define.RefreshEquipment, function()
		ClimbTowerGameManager:RefreshData()
	end)

	NetClient:Request("Account", "GetPower", function(value)
		ClimbTowerGameManager.CurrentPower = value
	end)
	
	NetClient:Request("Equipment", "ShowEquipment")
end

----------------------------------------------------------------------------------------------------------
-- Game Phase

local isEntering = false

function ClimbTowerGameManager:Enter(index)
	if ClimbTowerGameLoop.GamePhase ~= ClimbTowerDefine.GamePhase.Idle then return end 
	
	if isEntering then return end
	isEntering = true
	
	SoundManager:PlaySFX(ClimbTowerGameManager.ToolData.Sfx)
	NetClient:Request("ClimbTower", "Enter", { Index = index }, function(success)
		if success then
			EventManager:Dispatch(EventManager.Define.GameStart)			
			NetClient:Request("Equipment", "HideEquipment")
		end
		
		isEntering = false
	end)
end

function ClimbTowerGameManager:ArriveEnd(index)
	NetClient:Request("ClimbTower", "ArriveEnd")
end

function ClimbTowerGameManager:Slide(index)
	if ClimbTowerGameLoop.GamePhase ~= ClimbTowerDefine.GamePhase.Up and 
		ClimbTowerGameLoop.GamePhase ~=ClimbTowerDefine.GamePhase.ArriveEnd then
		return
	end
	
	local param = {
		ArriveDistance = ClimbTowerGameLoop.UpdateInfo.ArriveDistance
	}
	
	local player = game.Players.LocalPlayer
	PlayerAnimation:PlayAnimation(player, ClimbTowerDefine.Game.PlayerFallAnimation, true, 1)
	
	NetClient:Request("ClimbTower", "Slide", param)
	SpeedLineEffect:Enable()
end

function ClimbTowerGameManager:Exit(index)
	NetClient:Request("ClimbTower", "Exit", function()
		EventManager:Dispatch(EventManager.Define.GameFinish)
		SpeedLineEffect:Disable()
		
		local player = game.Players.LocalPlayer
		PlayerAnimation:StopAnimation(player, ClimbTowerDefine.Game.PlayerFallAnimation)
		
		NetClient:Request("Equipment", "ShowEquipment")
	end)
end

function ClimbTowerGameManager:GetWins(index)
	if ClimbTowerGameLoop.GamePhase == ClimbTowerDefine.GamePhase.ArriveEnd then
		NetClient:Request("ClimbTower", "GetWins")
	end
end

function ClimbTowerGameManager:GetCoin(index)
	NetClient:Request("ClimbTower", "GetCoin")
end

----------------------------------------------------------------------------------------------------------
-- Dig

function ClimbTowerGameManager:ResetDigArea()
	TerrainManager:Create(ClimbTowerDefine.Game.DigAreaPos, ClimbTowerDefine.Game.DigAreaSize)
	DigAreaRewardManager:Reset()
	--TerrainManager:CreateCylinder(ClimbTowerDefine.Game.DigAreaPos, ClimbTowerDefine.Game.DigAreaRadius, ClimbTowerDefine.Game.DigAreaHeight)
end

ClimbTowerGameManager.IsDigPhase = false

ClimbTowerGameManager.IsDigging = false
ClimbTowerGameManager.DigIntervalTimer = 999
ClimbTowerGameManager.DigAreaResetTimer = 0


ClimbTowerGameManager.ToolData = nil
ClimbTowerGameManager.EquipmentData = nil

ClimbTowerGameManager.CurrentPower = 0

function ClimbTowerGameManager:RefreshData()
	NetClient:Request("Equipment", "GetEquip", function(equipmentInfo)
		local equipmentData = ConfigManager:GetData("Equipment", equipmentInfo.ID)
		ClimbTowerGameManager.EquipmentData = equipmentData
		TerrainManager:SetDigRadius(equipmentData.DigRadius)
		
		PlayerAnimation:PreloadAnimation(equipmentData.DigAnimation)
	end)

	NetClient:Request("Tool", "GetEquip", function(toolInfo)
		local toolData = ConfigManager:GetData("Tool", toolInfo.ID)
		ClimbTowerGameManager.ToolData = toolData
		
		local uiGameInfo = require(game.ReplicatedStorage.ScriptAlias.UIClimbTowerGameInfo)
		uiGameInfo:RefreshToolInfo()
	end)
end

function ClimbTowerGameManager:EnterDig()
	ClimbTowerGameManager.IsDigPhase = true
	ClimbTowerGameManager.IsDigging = false
	ClimbTowerGameManager.DigIntervalTimer = 999999
	--print(equipmentData)
	
	EventManager:Dispatch(ClimbTowerDefine.Event.EnterDig)
end

function ClimbTowerGameManager:ExitDig()
	ClimbTowerGameManager.IsDigPhase = false
	ClimbTowerGameManager.IsDigging = false
	EventManager:Dispatch(ClimbTowerDefine.Event.ExitDig)
end

function ClimbTowerGameManager:CheckDigPackageFull()
	return ClimbTowerGameManager.CurrentPower >= ClimbTowerGameManager.ToolData.PowerCapacity
end

function ClimbTowerGameManager:CheckCanDig()
	if not ClimbTowerGameManager.IsDigPhase then return false end
	local c1 = ClimbTowerGameManager.DigIntervalTimer >= ClimbTowerGameManager.EquipmentData.DigInterval
	local c2 = not ClimbTowerGameManager:CheckDigPackageFull()
	if not c2 then
		UIManager:ShowMessage(Define.Message.PowerFull)
	end
	
	return c1 and c2
	
	--UIManager:ShowMessage(Define.Message.PowerFull)
end

function ClimbTowerGameManager:DigGetPower()
	NetClient:Request("ClimbTower", "DigGetPower", function(result)
		
	end)
end

function ClimbTowerGameManager:OnDigSuccess(success, hitPos)
	local player = game.Players.LocalPlayer
	
	ClimbTowerGameManager.IsDigging = true
	SoundManager:PlaySFX(SoundManager.Define.Dig)
	ClimbTowerGameManager:DigGetPower()
	ClimbTowerGameManager.DigIntervalTimer = 0
	
	local fxPrefab = ResourcesManager:Load(ClimbTowerDefine.Game.DigFx)
	Util:SpawnFxEmit(fxPrefab, hitPos, 20, 1)
	
	local equipmentData = ClimbTowerGameManager.EquipmentData
	local animationID = equipmentData.DigAnimation
	PlayerAnimation:PlayAnimation(player, animationID, false, equipmentData.AnimationSpeed)
	task.delay(equipmentData.DigInterval * 0.8, function()
		PlayerAnimation:StopAnimation(player, animationID)
	end)
	
	task.delay(equipmentData.DigInterval, function()
		ClimbTowerGameManager.IsDigging = false
	end)
end

function ClimbTowerGameManager:OnDigFail()

end

function ClimbTowerGameManager:DigUpdate(deltaTime)
	if not ClimbTowerGameManager.IsDigPhase then return end
	
	ClimbTowerGameManager.DigIntervalTimer += deltaTime
	
	-- 自动挖掘
	if ClimbTowerAutoPlay.Info.IsAutoDig then
		if not ClimbTowerGameManager:CheckDigPackageFull() and
			ClimbTowerGameManager:CheckCanDig() then
			TerrainManager:DigDown(ClimbTowerGameManager.EquipmentData.DigRadius, function(success, hitPos)
				ClimbTowerGameManager:OnDigSuccess(success, hitPos)
				ClimbTowerGameManager.DigIntervalTimer = -0.1
			end, function()
				ClimbTowerGameManager:OnDigFail()
			end)
		end
	end
	
	-- 自动刷新地形
	ClimbTowerGameManager.DigAreaResetTimer += deltaTime
	if ClimbTowerGameManager.DigAreaResetTimer >= ClimbTowerDefine.Game.DigAreaResetTime then
		ClimbTowerGameManager.DigAreaResetTimer = 0
		ClimbTowerGameManager:ResetToDigArea()
		ClimbTowerGameManager:ResetDigArea()
	end
end

----------------------------------------------------------------------------------------------------------
-- Reset Pos

function ClimbTowerGameManager:ResetToDigArea()
	NetClient:Request("ClimbTower", "ResetToDigArea", function()
		
	end)
end

function ClimbTowerGameManager:ResetToTower()
	NetClient:Request("ClimbTower", "ResetToTower", function()

	end)
end

----------------------------------------------------------------------------------------------------------
-- On Server Event

function ClimbTowerGameManager:OnUpdateGameInfo(broadcastInfo)
	ClimbTowerGameManager.UpdateGameInfo = broadcastInfo
end

return ClimbTowerGameManager
