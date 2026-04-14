local UserInputService = game:GetService("UserInputService")

local TouchUtil = require(game.ReplicatedStorage.ScriptAlias.TouchUtil)
local MouseUtil = require(game.ReplicatedStorage.ScriptAlias.MouseUtil)

local InputManager = {}

function InputManager:HandleAction(func)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		-- 鼠标左键点击
		local c1 = input.UserInputType == Enum.UserInputType.MouseButton1
		-- 手柄扳机键
		local c2 = input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonR1
		-- 手柄确认键
		local c3 = input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonA
		if c1 or c2 or c3 then
			func()
		end		
	end)

	-- 触控点击
	UserInputService.TouchTap:Connect(function(touchPositions, gameProcessed)
		if gameProcessed then return end
		local touchPos = touchPositions[1]
		if not touchPos then return end

		if not TouchUtil:IsOnGUI(touchPos) then
			func()
		end	
	end)
end

return InputManager
