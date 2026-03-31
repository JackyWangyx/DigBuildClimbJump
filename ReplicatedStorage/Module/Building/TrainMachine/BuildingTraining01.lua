local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining01 = {}

function BuildingTraining01:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 1)
end

return BuildingTraining01