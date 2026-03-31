local BuildingPetLoot = require(game.ReplicatedStorage.ScriptAlias.BuildingPetLoot)

local BuildingPetLootMythical = {}

function BuildingPetLootMythical:Init(buildingPart, opts)
	BuildingPetLoot:Handle(buildingPart, opts, "PetLoot11", "Egg/Egg11")
end

return BuildingPetLootMythical
