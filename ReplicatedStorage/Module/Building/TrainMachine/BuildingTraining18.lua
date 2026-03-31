local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining18 = {}

function BuildingTraining18:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 18)
end

return BuildingTraining18