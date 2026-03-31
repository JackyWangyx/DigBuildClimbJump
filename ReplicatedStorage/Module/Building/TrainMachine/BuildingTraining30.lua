local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining30 = {}

function BuildingTraining30:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 30)
end

return BuildingTraining30