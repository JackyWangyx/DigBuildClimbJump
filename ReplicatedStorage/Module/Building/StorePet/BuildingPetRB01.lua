local BuildingPetIAP = require(game.ReplicatedStorage.ScriptAlias.BuildingPetIAP)

local Define = require(game.ReplicatedStorage.Define)

local BuildingPetRB01 = {}

function BuildingPetRB01:Init(buildingPart, opts)
	local petID = 151
	BuildingPetIAP:Handle(buildingPart, opts, petID)
end

return BuildingPetRB01
