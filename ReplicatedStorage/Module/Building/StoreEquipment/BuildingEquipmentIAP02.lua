local BuildingEquipmentIAP = require(game.ReplicatedStorage.ScriptAlias.BuildingEquipmentIAP)

local Define = require(game.ReplicatedStorage.Define)

local BuildingEquipmentIAP02 = {}

function BuildingEquipmentIAP02:Init(buildingPart, opts)
	local EquipmentID = 12
	BuildingEquipmentIAP:Handle(buildingPart, opts, EquipmentID)
end

return BuildingEquipmentIAP02