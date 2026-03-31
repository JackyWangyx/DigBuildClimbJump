local gui = script.Parent
local CreateConfetti = require(gui:WaitForChild("ConfettiCreator"))

local Frame = script.Parent
Frame:GetPropertyChangedSignal("Enabled"):Connect(function()
	if Frame.Enabled then
		Play()
	end
end)

function Play()
	CreateConfetti.create(UDim2.new(1, 0, 0, 0), 20)
end
