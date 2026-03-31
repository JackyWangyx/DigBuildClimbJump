local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining04 = {}

function BuildingTraining04:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 4)
end

return BuildingTraining04