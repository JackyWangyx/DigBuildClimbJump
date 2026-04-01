local BuildingToolIAP = require(game.ReplicatedStorage.ScriptAlias.BuildingToolIAP)

local Define = require(game.ReplicatedStorage.Define)

local BuildingToolIAPRB01 = {}

function BuildingToolIAPRB01:Init(buildingPart, opts)
	local toolID = 26
	BuildingToolIAP:Handle(buildingPart, opts, toolID)
end

return BuildingToolIAPRB01
