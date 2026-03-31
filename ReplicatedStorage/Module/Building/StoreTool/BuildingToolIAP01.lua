local BuildingToolIAP = require(game.ReplicatedStorage.ScriptAlias.BuildingToolIAP)

local Define = require(game.ReplicatedStorage.Define)

local BuildingToolIAP01 = {}

function BuildingToolIAP01:Init(buildingPart, opts)
	local toolID = 25
	BuildingToolIAP:Handle(buildingPart, opts, toolID)
end

return BuildingToolIAP01
