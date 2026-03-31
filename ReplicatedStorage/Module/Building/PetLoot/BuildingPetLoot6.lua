local BuildingPetLoot = require(game.ReplicatedStorage.ScriptAlias.BuildingPetLoot)

local BuildingPetLootMythical = {}

function BuildingPetLootMythical:Init(buildingPart, opts)
	BuildingPetLoot:Handle(buildingPart, opts, "PetLoot6", "Egg/Egg06")
end

return BuildingPetLootMythical
