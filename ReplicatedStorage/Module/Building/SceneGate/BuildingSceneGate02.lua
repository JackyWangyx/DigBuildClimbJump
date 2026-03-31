local SceneGate = require(game.ReplicatedStorage.ScriptAlias.SceneGate)

local BuildingSceneGate02 = {}

function BuildingSceneGate02:Init(buildingPart, opts)
	SceneGate:Handle(buildingPart, opts, 2)
end

return BuildingSceneGate02
