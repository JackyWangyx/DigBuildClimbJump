local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining16 = {}

function BuildingTraining16:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 16)
end

return BuildingTraining16