local BuildingPartnerIAP= require(game.ReplicatedStorage.ScriptAlias.BuildingPartnerIAP)

local Define = require(game.ReplicatedStorage.Define)

local BuildingPartnerIAP02 = {}

function BuildingPartnerIAP02:Init(buildingPart, opts)
	local partnerID = 13
	BuildingPartnerIAP:Handle(buildingPart, opts, partnerID)
end

return BuildingPartnerIAP02
