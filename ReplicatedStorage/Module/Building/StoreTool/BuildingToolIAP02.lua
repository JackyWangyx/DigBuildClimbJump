local BuildingToolIAP = require(game.ReplicatedStorage.ScriptAlias.BuildingToolIAP)

local Define = require(game.ReplicatedStorage.Define)

local BuildingToolIAP02 = {}

function BuildingToolIAP02:Init(buildingPart, opts)
	local toolID = 26
	BuildingToolIAP:Handle(buildingPart, opts, toolID)
end

return BuildingToolIAP02
