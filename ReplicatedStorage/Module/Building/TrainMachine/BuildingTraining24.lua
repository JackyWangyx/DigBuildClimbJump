local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining24 = {}

function BuildingTraining24:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 24)
end

return BuildingTraining24