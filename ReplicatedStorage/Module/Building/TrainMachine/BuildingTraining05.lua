local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining05 = {}

function BuildingTraining05:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 5)
end

return BuildingTraining05