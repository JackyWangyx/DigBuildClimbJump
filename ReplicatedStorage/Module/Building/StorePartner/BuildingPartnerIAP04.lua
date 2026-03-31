local BuildingPartnerIAP= require(game.ReplicatedStorage.ScriptAlias.BuildingPartnerIAP)

local Define = require(game.ReplicatedStorage.Define)

local BuildingPartnerIAP04 = {}

function BuildingPartnerIAP04:Init(buildingPart, opts)
	local partnerID = 15
	BuildingPartnerIAP:Handle(buildingPart, opts, partnerID)
end

return BuildingPartnerIAP04
