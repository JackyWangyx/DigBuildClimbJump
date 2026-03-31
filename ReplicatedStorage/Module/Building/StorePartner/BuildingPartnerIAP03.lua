local BuildingPartnerIAP= require(game.ReplicatedStorage.ScriptAlias.BuildingPartnerIAP)

local Define = require(game.ReplicatedStorage.Define)

local BuildingPartnerIAP03 = {}

function BuildingPartnerIAP03:Init(buildingPart, opts)
	local partnerID = 14
	BuildingPartnerIAP:Handle(buildingPart, opts, partnerID)
end

return BuildingPartnerIAP03
