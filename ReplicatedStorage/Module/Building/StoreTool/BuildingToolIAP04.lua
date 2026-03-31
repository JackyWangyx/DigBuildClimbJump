local BuildingToolIAP = require(game.ReplicatedStorage.ScriptAlias.BuildingToolIAP)

local Define = require(game.ReplicatedStorage.Define)

local BuildingToolIAP04 = {}

function BuildingToolIAP04:Init(buildingPart, opts)
	local toolID = 28
	BuildingToolIAP:Handle(buildingPart, opts, toolID)
end

return BuildingToolIAP04
