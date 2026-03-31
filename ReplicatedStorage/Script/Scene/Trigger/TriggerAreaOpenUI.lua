local TriggerArea = require(game.ReplicatedStorage.ScriptAlias.TriggerArea)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)

local TriggerAreaOpenUI = {}

function TriggerAreaOpenUI:Handle(triggerArea, uiName, param)
	TriggerArea:Handle(triggerArea,
		function()
			UIManager:ShowAndHideOther(uiName, param)
		end, 
		function()
			UIManager:Hide(uiName)
		end, true)
end

return TriggerAreaOpenUI
