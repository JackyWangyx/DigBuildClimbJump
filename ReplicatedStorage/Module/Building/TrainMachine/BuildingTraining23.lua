local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local BuildingTraining23 = {}

function BuildingTraining23:Init(buildingPart, opts)
	TrainingMachine:Handle(buildingPart, opts, 23)
end

return BuildingTraining23