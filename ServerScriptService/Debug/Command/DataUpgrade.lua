local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local ServerPrefs = require(game.ServerScriptService.ScriptAlias.ServerPrefs)
local DataMoveTool = require(game.ServerScriptService.ScriptAlias.DataMoveTool)

local Define = require(game.ReplicatedStorage.Define)

local DataUpgrade = {}

DataUpgrade.Icon = "⚠️"
DataUpgrade.Color = Color3.new(1, 0.307256, 0)

--function DataUpgrade:UpgradeGameRank(player, param)
--	local oldValue = DataMoveTool:Get("GameRank", "RankList") or {}
--	for _, rankKey in pairs(Define.RankList) do
--		local rankList = oldValue.RankList[rankKey] or {}
--		local newRankKey = "RankList_"..rankKey
--		local value = {
--			RankList = rankList
--		}
--		DataMoveTool:Set("GameRank", newRankKey, value)
--		task.wait(0.5)
--	end
--end

--function DataUpgrade:DeleteOldRank(player, param)
--	DataMoveTool:Remove("GameRank", "RankList")
--end


return DataUpgrade
