local BuildingPetLoot = require(game.ReplicatedStorage.ScriptAlias.BuildingPetLoot)

local BuildingPetLootMythical = {}

function BuildingPetLootMythical:Init(buildingPart, opts)
	BuildingPetLoot:Handle(buildingPart, opts, "PetLoot102", "Egg/Egg102")
end

return BuildingPetLootMythical
