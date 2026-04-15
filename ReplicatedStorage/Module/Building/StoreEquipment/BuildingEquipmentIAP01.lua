local BuildingEquipmentIAP = require(game.ReplicatedStorage.ScriptAlias.BuildingEquipmentIAP)

local Define = require(game.ReplicatedStorage.Define)

local BuildingEquipmentIAP01 = {}

function BuildingEquipmentIAP01:Init(buildingPart, opts)
	local EquipmentID = 11
	BuildingEquipmentIAP:Handle(buildingPart, opts, EquipmentID)
end

return BuildingEquipmentIAP01