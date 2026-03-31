local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)

local ClickGameDefine = {}

ClickGameDefine.Game = {
	ContainerWidth = 1.0,
	ContainerHeight = 1.0,

	RandMoveDistanceMin = 0.05,
	RandMoveDistanceMax = 0.1,
	
	AutoClickInterval = 0.25,
}

ClickGameDefine.DefaultParam = {
	SpawnIntervalMin = 3,
	SpawnIntervalMax = 5,
	SpawnCountLimit = 5,
	LifeTimeDuration = 2,
	ItemPrefab = "UIItem/UIClickGameItem",
}

return ClickGameDefine