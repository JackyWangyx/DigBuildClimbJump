local BuildingPetLoot = require(game.ReplicatedStorage.ScriptAlias.BuildingPetLoot)

local BuildingPetLootMythical = {}

function BuildingPetLootMythical:Init(buildingPart, opts)
	BuildingPetLoot:Handle(buildingPart, opts, "PetLoot8", "Egg/Egg08")
end

return BuildingPetLootMythical
