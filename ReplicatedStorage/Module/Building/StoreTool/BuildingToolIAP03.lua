local BuildingToolIAP = require(game.ReplicatedStorage.ScriptAlias.BuildingToolIAP)

local Define = require(game.ReplicatedStorage.Define)

local BuildingToolIAP03 = {}

function BuildingToolIAP03:Init(buildingPart, opts)
	local toolID = 27
	BuildingToolIAP:Handle(buildingPart, opts, toolID)
end

return BuildingToolIAP03
