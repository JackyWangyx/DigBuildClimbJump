local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining13 = {}

function BuildingTraining13:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 13)
end

return BuildingTraining13