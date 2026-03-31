local BuildingPetLoot = require(game.ReplicatedStorage.ScriptAlias.BuildingPetLoot)

local BuildingPetLootMythical = {}

function BuildingPetLootMythical:Init(buildingPart, opts)
	BuildingPetLoot:Handle(buildingPart, opts, "PetLoot3", "Egg/Egg03")
end

return BuildingPetLootMythical
