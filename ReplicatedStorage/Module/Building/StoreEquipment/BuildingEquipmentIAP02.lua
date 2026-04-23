local BuildingEquipmentIAP = require(game.ReplicatedStorage.ScriptAlias.BuildingEquipmentIAP)

local Define = require(game.ReplicatedStorage.Define)

local BuildingEquipmentIAP02 = {}

function BuildingEquipmentIAP02:Init(buildingPart, opts)
	local toolID = 12
	BuildingEquipmentIAP:Handle(buildingPart, opts, toolID)
end

return BuildingEquipmentIAP02