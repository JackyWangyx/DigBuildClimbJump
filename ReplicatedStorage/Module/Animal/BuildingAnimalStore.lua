local ProximityAreaOpenUI = require(game.ReplicatedStorage.ScriptAlias.ProximityAreaOpenUI)
local TriggerAreaOpenUI = require(game.ReplicatedStorage.ScriptAlias.TriggerAreaOpenUI)
local Building = require(game.ReplicatedStorage.ScriptAlias.Building)

local BuildingAnimalStore = {}

function BuildingAnimalStore:Init(buildingPart, opts)
	local building = Building.TriggerOpenUI(buildingPart, opts, "AnimalStore")
end

return BuildingAnimalStore
