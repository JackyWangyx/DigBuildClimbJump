local ProximityAreaOpenUI = require(game.ReplicatedStorage.ScriptAlias.ProximityAreaOpenUI)
local TriggerAreaOpenUI = require(game.ReplicatedStorage.ScriptAlias.TriggerAreaOpenUI)
local Building = require(game.ReplicatedStorage.ScriptAlias.Building)

local BuildingPetUpgrade = {}

function BuildingPetUpgrade:Init(buildingPart, opts)
	local building = Building.TriggerOpenUI(buildingPart, opts, "PetUpgrade")
end

return BuildingPetUpgrade
