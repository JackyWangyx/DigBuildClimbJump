local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining15 = {}

function BuildingTraining15:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 15)
end

return BuildingTraining15