local UserInputService = game:GetService("UserInputService")

local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)

local DebugWindow = require(script.Parent.DebugWindow)

local DebugClient = {}

function DebugClient:Init()
	task.wait()
	
	local player = game.Players.LocalPlayer
	NetClient:Request("Debug", "IsGameOwner", nil, function(result)
		if not result then
			return
		end

		local debugWindow = DebugWindow:CreateWindow()
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not gameProcessed and input.KeyCode == Enum.KeyCode.F2 then
				debugWindow.Enabled = not debugWindow.Enabled
			end
		end)
		
		local touchCount = 0
		UserInputService.TouchStarted:Connect(function(_, gameProcessed)
			touchCount = touchCount + 1
			if gameProcessed then return end
			if touchCount == 5 then
				debugWindow.Enabled = not debugWindow.Enabled
			end
		end)
		
		UserInputService.TouchEnded:Connect(function(_, gameProcessed)
			touchCount = touchCount - 1
			if gameProcessed then return end
		end)
	end)
end

return DebugClient