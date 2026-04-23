local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local LogUtil = require(game.ReplicatedStorage.ScriptAlias.LogUtil)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local TimeUtil = require(game.ReplicatedStorage.ScriptAlias.TimeUtil)
local NpcManager = require(game.ReplicatedStorage.ScriptAlias.NpcManager)
local SceneManager = require(game.ReplicatedStorage.ScriptAlias.SceneManager)

local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)
local GameRank = require(game.ServerScriptService.ScriptAlias.GameRank)

local Define = require(game.ReplicatedStorage.Define)

local GameRankServerHandler = {}

GameRankServerHandler.DanceAnimationList = {
	"rbxassetid://507771019",
	"rbxassetid://507771955",
	"rbxassetid://507772104",
}

GameRankServerHandler.RankBuildingDic = {
	["TotalGetPower"] = "BuildingRankGetPower",
	["TotalGetCoin"] = "BuildingRankGetCoin",
	["TotalGetWins"] = "BuildingRankGetWins",
	["TotalRebirth"] = "BuildingRankRebirth",
	["TotalClick"] = "BuildingRankClick",
	["TotalDonate"] = "BuildingRankDonate",
}

GameRankServerHandler.Cache = {}

function GameRankServerHandler:Init()
	for rankKey, rankBuildingName in pairs(GameRankServerHandler.RankBuildingDic) do
		task.spawn(function()
			GameRankServerHandler:RefreshTopNpc(rankKey)
		end)
	end
	
	EventManager:Listen(EventManager.Define.RefreshRank, function(rankKey)
		task.spawn(function()
			GameRankServerHandler:RefreshTopNpc(rankKey)
		end)
	end)
end

---------------------------------------------------------------------------------------------------
-- Top Npc

function GameRankServerHandler:RefreshTopNpc(rankKey)
	local info = GameRankServerHandler.Cache[rankKey]
	if not info then
		info = {
			RankKey = rankKey,
		}
		
		local buildingName = GameRankServerHandler.RankBuildingDic[rankKey]
		local building = Util:GetChildByName(SceneManager.LevelRoot, buildingName)
		if building then
			info.Building = building
			
			local topPointList = {}
			
			local p1 = Util:GetChildByName(building, "Top1")
			table.insert(topPointList, p1)
			
			local p2 = Util:GetChildByName(building, "Top2")
			table.insert(topPointList, p2)
			
			local p3 = Util:GetChildByName(building, "Top3")
			table.insert(topPointList, p3)

			info.TopPointList = topPointList
		end
		
		GameRankServerHandler.Cache[rankKey] = info
	end
	
	if info.TopNpcList then
		for _, npc in ipairs(info.TopNpcList) do
			npc:Destroy()
		end
	end
	
	info.TopNpcList = {}
	if info.Building and info.TopPointList then
		local rankList = GameRank:GetRankList(rankKey)
		if not rankList then return end
		for index, data in ipairs(rankList) do
			if index > #rankList or index > #info.TopPointList then break end
			local point = info.TopPointList[index]
			
			local npc = NpcManager:CreateNpcFromPlayerID(data.PlayerID, point.CFrame)
			if npc then
				npc.Parent = info.Building
				npc.Name = "Top" .. index .. " - " .. npc.Name 
				NpcManager:ScaleNpc(npc, 1.2)

				local animationID = GameRankServerHandler.DanceAnimationList[index]
				NpcManager:PlayAnimation(npc, animationID, true)

				table.insert(info.TopNpcList, npc)
			end		
		end
	end	
end

return GameRankServerHandler
