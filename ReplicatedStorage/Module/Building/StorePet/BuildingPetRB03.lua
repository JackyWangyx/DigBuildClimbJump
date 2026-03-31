local BuildingPetIAP = require(game.ReplicatedStorage.ScriptAlias.BuildingPetIAP)

local Define = require(game.ReplicatedStorage.Define)

local BuildingPetRB03 = {}

function BuildingPetRB03:Init(buildingPart, opts)
	local petID = 161
	BuildingPetIAP:Handle(buildingPart, opts, petID)
end

return BuildingPetRB03
