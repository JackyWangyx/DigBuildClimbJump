local BuildingAnimalIAP = require(game.ReplicatedStorage.ScriptAlias.BuildingAnimalIAP)

local Define = require(game.ReplicatedStorage.Define)

local BuildingAnimalIAP01 = {}

function BuildingAnimalIAP01:Init(buildingPart, opts)
	local animalID = 1
	BuildingAnimalIAP:Handle(buildingPart, opts, animalID)
end

return BuildingAnimalIAP01
