local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local Camera = game.Workspace.CurrentCamera

local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local SceneManager = require(game.ReplicatedStorage.ScriptAlias.SceneManager)
local TriggerArea = require(game.ReplicatedStorage.ScriptAlias.TriggerArea)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local CameraManager = require(game.ReplicatedStorage.ScriptAlias.CameraManager)
local ClickGame = require(game.ReplicatedStorage.ScriptAlias.ClickGame)

local RunnerGameManager = {}

RunnerGameManager.GameRoot = nil
RunnerGameManager.FxRoot = nil
RunnerGameManager.TrackRoot = nil
RunnerGameManager.RoadRoot = nil
RunnerGameManager.StartTrigger = nil
RunnerGameManager.IsGaming = false

local SpeedLinesPrefab = nil
local SpeedLines = nil

local Humanoid = nil

function RunnerGameManager:Init()
	RunnerGameManager.GameRoot = SceneManager.LevelRoot:WaitForChild("Game")
	RunnerGameManager.FxRoot = RunnerGameManager.GameRoot:WaitForChild("Fx")
	RunnerGameManager.TrackRoot = RunnerGameManager.GameRoot:WaitForChild("Track")
	RunnerGameManager.RoadRoot = RunnerGameManager.GameRoot:WaitForChild("Road")
	RunnerGameManager.StartTrigger = RunnerGameManager.GameRoot:WaitForChild("StartTrigger"):WaitForChild("Trigger")
	
	TriggerArea:Handle(RunnerGameManager.StartTrigger, function()
		NetClient:Request("Game", "Enter", function(result)			
		end)
	end, function()

	end)
	
	SpeedLinesPrefab = Util:LoadPrefab("Fx/SpeedLines")
	RunnerGameManager.IsGaming = false
	UpdatorManager:RenderStepped(function()
		RunnerGameManager:OnRender()
	end)
	
	ClickGame:Init()
end

function RunnerGameManager:Exit()
	NetClient:Request("Game", "Leave", function()
		
	end)
end

function RunnerGameManager:OnEnter(player)
	PlayerManager:DisableControl(player)
	
	--CameraManager:MoveTo(SceneManager.LevelRoot.Game.StartTrigger.CFrame, 1)
end

function RunnerGameManager:OnStart(player)
	if SpeedLines then
		SpeedLines:Destroy()
		SpeedLines = nil
	end
	
	PlayerManager:EnableControl(player)
	SpeedLines = SpeedLinesPrefab:Clone()
	SpeedLines.Parent = Camera
	RunnerGameManager.IsGaming = true
	--PlayerManager:DisableControl(player)
end

function RunnerGameManager:OnLeave(player)
	RunnerGameManager.IsGaming = false
	if SpeedLines then
		SpeedLines:Destroy()
		SpeedLines = nil
	end
	
	task.delay(0.5, function()
		PlayerManager:EnableControl(player)
	end)
end

function RunnerGameManager:OnFinish(player)
	RunnerGameManager.IsGaming = false
	if SpeedLines then
		SpeedLines:Destroy()
		SpeedLines = nil
	end
end

function RunnerGameManager:OnRender()
	if not RunnerGameManager.IsGaming then return end
	
	local offset = 10
	local viewportSize = Camera.ViewportSize
	local aspectRatio = viewportSize.X / viewportSize.Y
	
	if aspectRatio > 1.5 then
		offset = 10
	else
		offset = 13
	end
	
	SpeedLines.CFrame = Camera.CFrame + Camera.CFrame.LookVector * (offset / (Camera.FieldOfView / 70))
	--SpeedLines.Attachment.ParticleEmitter.Rate = (Humanoid.)
end

return RunnerGameManager
