local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining14 = {}

function BuildingTraining14:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 14)
end

return BuildingTraining14