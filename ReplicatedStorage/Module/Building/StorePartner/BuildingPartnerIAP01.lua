local BuildingPartnerIAP= require(game.ReplicatedStorage.ScriptAlias.BuildingPartnerIAP)

local Define = require(game.ReplicatedStorage.Define)

local BuildingPartnerIAP01 = {}

function BuildingPartnerIAP01:Init(buildingPart, opts)
	local partnerID = 12
	BuildingPartnerIAP:Handle(buildingPart, opts, partnerID)
end

return BuildingPartnerIAP01
