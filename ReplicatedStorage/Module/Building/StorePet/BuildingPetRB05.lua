local BuildingPetIAP = require(game.ReplicatedStorage.ScriptAlias.BuildingPetIAP)

local Define = require(game.ReplicatedStorage.Define)

local BuildingPetRB05 = {}

function BuildingPetRB05:Init(buildingPart, opts)
	local petID = 171
	BuildingPetIAP:Handle(buildingPart, opts, petID)
end

return BuildingPetRB05
