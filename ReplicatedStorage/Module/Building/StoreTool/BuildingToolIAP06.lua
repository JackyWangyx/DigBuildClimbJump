local BuildingToolIAP = require(game.ReplicatedStorage.ScriptAlias.BuildingToolIAP)

local Define = require(game.ReplicatedStorage.Define)

local BuildingToolIAP06 = {}

function BuildingToolIAP06:Init(buildingPart, opts)
	local toolID = 30
	BuildingToolIAP:Handle(buildingPart, opts, toolID)
end

return BuildingToolIAP06
