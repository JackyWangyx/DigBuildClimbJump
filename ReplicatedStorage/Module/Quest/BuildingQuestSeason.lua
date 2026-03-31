local ProximityAreaOpenUI = require(game.ReplicatedStorage.ScriptAlias.ProximityAreaOpenUI)
local TriggerAreaOpenUI = require(game.ReplicatedStorage.ScriptAlias.TriggerAreaOpenUI)
local Building = require(game.ReplicatedStorage.ScriptAlias.Building)

local BuildingQuestSeason = {}

function BuildingQuestSeason:Init(buildingPart, opts)
	local building = Building.TriggerOpenUI(buildingPart, opts, "UIQuestSeason")
end

return BuildingQuestSeason
