local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining22 = {}

function BuildingTraining22:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 22)
end

return BuildingTraining22