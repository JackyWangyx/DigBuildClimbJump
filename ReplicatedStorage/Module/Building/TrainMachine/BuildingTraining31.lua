local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining31 = {}

function BuildingTraining31:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 31)
end

return BuildingTraining31