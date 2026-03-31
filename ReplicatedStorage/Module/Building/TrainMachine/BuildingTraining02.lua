local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining02= {}

function BuildingTraining02:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 2)
end

return BuildingTraining02