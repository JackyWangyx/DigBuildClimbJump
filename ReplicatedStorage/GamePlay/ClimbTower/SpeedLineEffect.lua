local Camera = game.Workspace.CurrentCamera

local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local SpeedLineEffect = {}

local SpeedLinesPrefab = nil
local SpeedLines = nil
local IsRunning = false

function SpeedLineEffect:Init()
	SpeedLinesPrefab = Util:LoadPrefab("Fx/SpeedLines")
	
	UpdatorManager:RenderStepped(function()
		SpeedLineEffect:OnRender()
	end)
end

function SpeedLineEffect:Enable()
	SpeedLineEffect:Clear()
	
	SpeedLines = SpeedLinesPrefab:Clone()
	SpeedLines.Parent = Camera
	IsRunning = true
end

function SpeedLineEffect:Disable()
	SpeedLineEffect:Clear()
	IsRunning = false
end

function SpeedLineEffect:Clear()
	if SpeedLines then
		SpeedLines:Destroy()
		SpeedLines = nil
	end
end

function SpeedLineEffect:OnRender()
	if not IsRunning then return end
	
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

return SpeedLineEffect
