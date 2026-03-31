local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining21 = {}

function BuildingTraining21:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 21)
end

return BuildingTraining21