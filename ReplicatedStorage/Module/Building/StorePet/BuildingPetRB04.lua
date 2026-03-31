local BuildingPetIAP = require(game.ReplicatedStorage.ScriptAlias.BuildingPetIAP)

local Define = require(game.ReplicatedStorage.Define)

local BuildingPetRB04 = {}

function BuildingPetRB04:Init(buildingPart, opts)
	local petID = 166
	BuildingPetIAP:Handle(buildingPart, opts, petID)
end

return BuildingPetRB04
