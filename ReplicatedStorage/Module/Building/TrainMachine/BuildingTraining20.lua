local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining20 = {}

function BuildingTraining20:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 20)
end

return BuildingTraining20