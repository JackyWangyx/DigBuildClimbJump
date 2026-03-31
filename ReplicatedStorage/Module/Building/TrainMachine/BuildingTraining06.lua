local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining06 = {}

function BuildingTraining06:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 6)
end

return BuildingTraining06