local ProximityArea = require(game.ReplicatedStorage.ScriptAlias.ProximityArea)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)

local ProximityAreaOpenUI = {}

function ProximityAreaOpenUI:Handle(part, message, uiName, param)
	ProximityArea:Handle(part, message, function()
		UIManager:ShowAndHideOther(uiName, param)
	end)
end

return ProximityAreaOpenUI