local TouchUtil = {}

function TouchUtil:IsOnGUI(touchPos)
	local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	local guiObjects = playerGui:GetGuiObjectsAtPosition(touchPos.X, touchPos.Y)
	local isOnGUI = false
	for _, gui in ipairs(guiObjects) do
		if gui.Visible then
			if gui:IsA("GuiButton") or gui.Active then
				isOnGUI = true
				break
			end

			if (gui.BackgroundTransparency or 0) < 0.9 then
				isOnGUI = true
				break
			end
		end
	end

	return isOnGUI
end

return TouchUtil
