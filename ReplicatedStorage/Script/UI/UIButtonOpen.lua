local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)

local UIButtonOpen = {}

function UIButtonOpen:Handle(button, uiName, param)
	UIButton:Handle(button, function()
		UIManager:ShowAndHideOther(uiName, param)
	end)
end

return UIButtonOpen
