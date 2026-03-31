local BuildingToolIAP = require(game.ReplicatedStorage.ScriptAlias.BuildingToolIAP)

local Define = require(game.ReplicatedStorage.Define)

local BuildingToolIAP05 = {}

function BuildingToolIAP05:Init(buildingPart, opts)
	local toolID = 29
	BuildingToolIAP:Handle(buildingPart, opts, toolID)
end

return BuildingToolIAP05
