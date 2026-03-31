local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining08 = {}

function BuildingTraining08:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 8)
end

return BuildingTraining08