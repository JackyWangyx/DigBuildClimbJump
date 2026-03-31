local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining12 = {}

function BuildingTraining12:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 12)
end

return BuildingTraining12