local BuildingRank = require(game.ReplicatedStorage.ScriptAlias.BuildingRank)

local Define = require(game.ReplicatedStorage.Define)

local BuildingRankDonate = {}

function BuildingRankDonate:Init(buildingPart, opts)
	BuildingRank:Handle(buildingPart, opts, Define.RankList.TotalDonate, function(rankList)
		--BuildingRankDonate:OnRankList(buildingPart, rankList)
	end)
end

return BuildingRankDonate
