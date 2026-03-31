local GameRank = require(game.ServerScriptService.ScriptAlias.GameRank)

local Rank = {}

function Rank:GetRankList(player, param)
	local rankKey = param.RankKey
	local rankList = GameRank:GetRankList(rankKey)
	return rankList
end

return Rank
