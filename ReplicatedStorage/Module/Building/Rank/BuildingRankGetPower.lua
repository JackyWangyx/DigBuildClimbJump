local BuildingRank = require(game.ReplicatedStorage.ScriptAlias.BuildingRank)

local Define = require(game.ReplicatedStorage.Define)

local BuildingRankGetPower = {}

function BuildingRankGetPower:Init(buildingPart, opts)
	BuildingRank:Handle(buildingPart, opts, Define.RankList.TotalGetPower)
end

return BuildingRankGetPower
