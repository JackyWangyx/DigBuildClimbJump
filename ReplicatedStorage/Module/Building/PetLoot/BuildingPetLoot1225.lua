local BuildingPetLoot = require(game.ReplicatedStorage.ScriptAlias.BuildingPetLoot)

local BuildingPetLootNormal = {}

function BuildingPetLootNormal:Init(buildingPart, opts)
	BuildingPetLoot:Handle(buildingPart, opts, "PetLoot1", "Egg/Egg1225")
end

return BuildingPetLootNormal
