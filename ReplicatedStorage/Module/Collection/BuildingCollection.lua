local ProximityAreaOpenUI = require(game.ReplicatedStorage.ScriptAlias.ProximityAreaOpenUI)
local TriggerAreaOpenUI = require(game.ReplicatedStorage.ScriptAlias.TriggerAreaOpenUI)
local Building = require(game.ReplicatedStorage.ScriptAlias.Building)

local BuildingCollection = {}

function BuildingCollection:Init(buildingPart, opts)
	local building = Building.TriggerOpenUI(buildingPart, opts, "Collection")
end

return BuildingCollection
