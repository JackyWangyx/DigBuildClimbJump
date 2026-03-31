local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining07 = {}

function BuildingTraining07:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 7)
end

return BuildingTraining07