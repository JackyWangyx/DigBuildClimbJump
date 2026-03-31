local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining11 = {}

function BuildingTraining11:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 11)
end

return BuildingTraining11