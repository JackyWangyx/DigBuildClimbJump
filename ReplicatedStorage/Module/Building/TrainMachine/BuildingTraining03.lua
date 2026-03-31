local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining03 = {}

function BuildingTraining03:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 3)
end

return BuildingTraining03