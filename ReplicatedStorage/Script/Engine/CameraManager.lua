local RunService = game:GetService("RunService")

local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local UTween = require(game.ReplicatedStorage.ScriptAlias.UTween)
local Define = require(game.ReplicatedStorage.Define)

local CameraManager = {}

function CameraManager:Init()
	CameraManager:SetZoomRange(Define.Camera.ZoomMinDistance, Define.Camera.ZoomMaxDistance)
end

-- Param

function CameraManager:SetZoomRange(min, max)
	local player = game.Players.LocalPlayer
	player.CameraMinZoomDistance = min
	player.CameraMaxZoomDistance = max
end

-- Effect

local camera = game.Workspace.CurrentCamera

local ShakeDurationDefault = 0.4
local ShakePowerDefault    = 1.5

local FADE_OUT       = true 

local ShakeDuration
local ShakePower

local IsCameraShaking = false
local ShakeStartTime = 0

RunService.RenderStepped:Connect(function()
	if not IsCameraShaking then return end

	local timePassed = tick() - ShakeStartTime

	if timePassed >= ShakeDuration then
		IsCameraShaking = false
		return
	end

	local currentPower = ShakePower

	if FADE_OUT then
		local alpha = 1 - (timePassed / ShakeDuration)
		currentPower = ShakePower * alpha
	end

	local rx = (math.random() - 0.5) * 2 * currentPower
	local ry = (math.random() - 0.5) * 2 * currentPower
	local rz = (math.random() - 0.5) * 2 * currentPower

	camera.CFrame = camera.CFrame * CFrame.new(rx, ry, 0)
end)

function CameraManager:ShakeCamera(power, duration)
	ShakePower = power or ShakePowerDefault
	ShakeDuration = duration or ShakeDurationDefault
	
	IsCameraShaking = true
	ShakeStartTime = tick()
end

return CameraManager