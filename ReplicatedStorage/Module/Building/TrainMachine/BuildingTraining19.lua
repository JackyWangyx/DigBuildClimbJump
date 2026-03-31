local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining19 = {}

function BuildingTraining19:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 19)
end

return BuildingTraining19