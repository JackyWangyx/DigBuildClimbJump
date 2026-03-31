local ProximityAreaOpenUI = require(game.ReplicatedStorage.ScriptAlias.ProximityAreaOpenUI)
local TriggerAreaOpenUI = require(game.ReplicatedStorage.ScriptAlias.TriggerAreaOpenUI)
local Building = require(game.ReplicatedStorage.ScriptAlias.Building)

local BuildingPartnerStore = {}

function BuildingPartnerStore:Init(buildingPart, opts)
	local building = Building.TriggerOpenUI(buildingPart, opts, "PartnerStore")
end

return BuildingPartnerStore
