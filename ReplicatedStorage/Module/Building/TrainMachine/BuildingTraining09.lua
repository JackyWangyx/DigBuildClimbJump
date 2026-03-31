local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining09 = {}

function BuildingTraining09:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 9)
end

return BuildingTraining09