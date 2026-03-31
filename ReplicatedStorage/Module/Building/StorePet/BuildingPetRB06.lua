local BuildingPetIAP = require(game.ReplicatedStorage.ScriptAlias.BuildingPetIAP)

local Define = require(game.ReplicatedStorage.Define)

local BuildingPetRB06 = {}

function BuildingPetRB06:Init(buildingPart, opts)
	local petID = 176
	BuildingPetIAP:Handle(buildingPart, opts, petID)
end

return BuildingPetRB06
