local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining10 = {}

function BuildingTraining10:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 10)
end

return BuildingTraining10