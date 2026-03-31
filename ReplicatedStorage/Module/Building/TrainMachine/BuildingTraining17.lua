local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining17 = {}

function BuildingTraining17:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 17)
end

return BuildingTraining17