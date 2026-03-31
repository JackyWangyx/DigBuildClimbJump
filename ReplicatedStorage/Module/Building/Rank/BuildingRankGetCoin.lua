local BuildingRank = require(game.ReplicatedStorage.ScriptAlias.BuildingRank)

local Define = require(game.ReplicatedStorage.Define)

local BuildingRankGetCoin = {}

function BuildingRankGetCoin:Init(buildingPart, opts)
	BuildingRank:Handle(buildingPart, opts, Define.RankList.TotalGetCoin)
end

return BuildingRankGetCoin
