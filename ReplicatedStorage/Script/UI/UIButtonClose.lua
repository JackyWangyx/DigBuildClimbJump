local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)

local UIButtonClose = {}

function UIButtonClose:Handle(button)
	UIButton:Handle(button, function()
		local screenGui = Util:GetParentByType(button, "ScreenGui")
		if not screenGui then
			return
		end
		
		local uiName = screenGui.Name
		UIManager:Hide(uiName)
	end)
end

return UIButtonClose
