local TweenServiceManager = require(game.ReplicatedStorage.ScriptAlias.TweenServiceManager)

local UIIcon = {}

function UIIcon:HandleAnimation(button, icon)
	
	local tweenEnter = TweenServiceManager.New(icon)
		:To({ Rotation = 10 })
		:SetDuration(0.15)
		:SetEase(Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	
	local tweenLeave = TweenServiceManager.New(icon)
		:To({ Rotation = 0 })
		:SetDuration(0.15)
		:SetEase(Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	
	button.MouseEnter:Connect(function()
		tweenEnter:Play()
	end)
	
	button.MouseLeave:Connect(function()
		tweenLeave:Play()
	end)
end

return UIIcon
