local BuildingToolIAP = require(game.ReplicatedStorage.ScriptAlias.BuildingToolIAP)

local Define = require(game.ReplicatedStorage.Define)

local BuildingToolIAPRB02 = {}

function BuildingToolIAPRB02:Init(buildingPart, opts)
	local toolID = 27
	BuildingToolIAP:Handle(buildingPart, opts, toolID)
end

return BuildingToolIAPRB02
