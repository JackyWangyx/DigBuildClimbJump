local BuildingPetIAP = require(game.ReplicatedStorage.ScriptAlias.BuildingPetIAP)

local Define = require(game.ReplicatedStorage.Define)

local BuildingPetRB02 = {}

function BuildingPetRB02:Init(buildingPart, opts)
	local petID = 156
	BuildingPetIAP:Handle(buildingPart, opts, petID)
end

return BuildingPetRB02
