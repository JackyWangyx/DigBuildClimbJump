local BuildingRank = require(game.ReplicatedStorage.ScriptAlias.BuildingRank)

local Define = require(game.ReplicatedStorage.Define)

local BuildingRankGetWins = {}

function BuildingRankGetWins:Init(buildingPart, opts)
	BuildingRank:Handle(buildingPart, opts, Define.RankList.TotalGetWins)
end

return BuildingRankGetWins
