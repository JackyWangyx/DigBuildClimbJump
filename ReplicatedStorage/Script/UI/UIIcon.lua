local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local TweenServiceManager = require(game.ReplicatedStorage.ScriptAlias.TweenServiceManager)
local SoundManager = require(game.ReplicatedStorage.ScriptAlias.SoundManager)
local UIButtonToolTip = require(game.ReplicatedStorage.ScriptAlias.UIButtonTooltip)

local UIIcon = {}

local function CreateTween(target, props, duration)
	return TweenServiceManager.New(target)
		:To(props)
		:SetDuration(duration)
		:SetEase(Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
end

function UIIcon:Handle(icon)
	local iconTween
	local function PlayIcon(rotation)
		if not icon then return end
		if iconTween then
			iconTween:Stop()
		end

		iconTween = CreateTween(icon, { Rotation = rotation }, 0.15)
		iconTween:Play()
	end
	
	icon.MouseEnter:Connect(function()
		PlayIcon(15)
	end)
	
	icon.MouseLeave:Connect(function()
		PlayIcon(0)
	end)
end

return UIIcon