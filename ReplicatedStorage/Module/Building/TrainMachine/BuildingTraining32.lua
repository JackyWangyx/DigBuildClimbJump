local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining32 = {}

function BuildingTraining32:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 32)
end

return BuildingTraining32