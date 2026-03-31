local BuildingRank = require(game.ReplicatedStorage.ScriptAlias.BuildingRank)

local Define = require(game.ReplicatedStorage.Define)

local BuildingRankClick = {}

function BuildingRankClick:Init(buildingPart, opts)
	BuildingRank:Handle(buildingPart, opts, Define.RankList.TotalClick)
end

return BuildingRankClick
