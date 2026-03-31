local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local GameRank = require(game.ServerScriptService.ScriptAlias.GameRank)
local ServerPrefs = require(game.ServerScriptService.ScriptAlias.ServerPrefs)

local Define = require(game.ReplicatedStorage.Define)

local RankList = {}

RankList.Icon = "🥈"
RankList.Color = Color3.new(0.85098, 0.933333, 0.623529)

function RankList:LogCoin(player, param)
	local info = GameRank:GetRankList(Define.RankList.TotalGetCoin)
	print(info)
end

function RankList:LogPower(player, param)
	local info = GameRank:GetRankList(Define.RankList.TotalGetPower)
	print(info)
end

function RankList:LogClick(player, param)
	local info = GameRank:GetRankList(Define.RankList.TotalClick)
	print(info)
end

function RankList:LogRebirth(player, param)
	local info = GameRank:GetRankList(Define.RankList.TotalRebirth)
	print(info)
end

function RankList:LogSave(player, param)
	local info = ServerPrefs:GetModule("GameRank", "RankList")
	print(info)
end

function RankList:Clear(player, param)
	for _, rankKey in pairs(Define.RankList) do
		local key = "RankList_"..rankKey
		ServerPrefs:SetValue("GameRank", key, "RankList", {})
		ServerPrefs:SaveToDataStore("GameRank", key)
		print("Clear", rankKey)
	end
end


return RankList
