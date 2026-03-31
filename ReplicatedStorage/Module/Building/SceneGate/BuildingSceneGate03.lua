local SceneGate = require(game.ReplicatedStorage.ScriptAlias.SceneGate)

local BuildingSceneGate03 = {}

function BuildingSceneGate03:Init(buildingPart, opts)
	SceneGate:Handle(buildingPart, opts, 3)
end

return BuildingSceneGate03
