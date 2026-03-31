local SceneGate = require(game.ReplicatedStorage.ScriptAlias.SceneGate)

local BuildingSceneGate01 = {}

function BuildingSceneGate01:Init(buildingPart, opts)
	SceneGate:Handle(buildingPart, opts, 1)
end

return BuildingSceneGate01
