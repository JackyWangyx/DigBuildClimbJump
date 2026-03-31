local UserInput = game:GetService("UserInputService")
local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)

local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local SoundManager = require(game.ReplicatedStorage.ScriptAlias.SoundManager)

local UIButtonTooltip = {}

function UIButtonTooltip:Handle(button)
	local tooltip = button:FindFirstChild("Tooltip")
	if not tooltip then return end
	
	local isHovering = false
	tooltip.Visible = false
	
	UpdatorManager:RenderStepped(function()
		--if isHovering then
		--	local mousePos = UserInput:GetMouseLocation()
		--	tooltip.Position = UDim2.new(0, mousePos.X + 10, 0, mousePos.Y + 10)
		--end
	end)

	button.MouseEnter:Connect(function()
		isHovering = true
		tooltip.Visible = true
	end)

	button.MouseLeave:Connect(function()
		isHovering = false
		tooltip.Visible = false
	end)
end

return UIButtonTooltip
