local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining25 = {}

function BuildingTraining25:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 25)
end

return BuildingTraining25