local BuildingEquipmentIAP = require(game.ReplicatedStorage.ScriptAlias.BuildingEquipmentIAP)

local Define = require(game.ReplicatedStorage.Define)

local BuildingEquipmentIAP01 = {}

function BuildingEquipmentIAP01:Init(buildingPart, opts)
	local toolID = 11
	BuildingEquipmentIAP:Handle(buildingPart, opts, toolID)
end

return BuildingEquipmentIAP01