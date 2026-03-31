local RunService = game:GetService("RunService")

local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local LogUtil = require(game.ReplicatedStorage.ScriptAlias.LogUtil)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local ServerPrefs = require(game.ServerScriptService.ScriptAlias.ServerPrefs)
local PlayerCache = require(game.ServerScriptService.ScriptAlias.PlayerCache)

local BanUserList = require(game.ServerStorage.BanUserList)

local Define = require(game.ReplicatedStorage.Define)

local GameRank = {}

local GameRankCache = {}			-- 缓存排行榜
local UpdateRankCache = {}			-- 当前服务器修改过的记录

local LastUpdateTime = 0
local UpdateInterval = Define.Data.GameRankSaveInterval

local function NearlyEqual(a, b, eps)
	eps = eps or 1e-6
	return math.abs(a - b) < eps
end

local function CheckNeedMerge(serverList, localList)
	if #serverList ~= #localList then return true end
	for i, a in ipairs(serverList) do
		local b = localList[i]
		if not b 
			or a.PlayerID ~= b.PlayerID
			or not NearlyEqual(a.Value, b.Value, 1e-6)
			or a.Rank ~= b.Rank then
			return true
		end
	end
	return false
end

local function CheckNeedUpdate(rankKey)
	local cache = UpdateRankCache[rankKey]
	if cache == nil then return false end
	if next(cache) ~= nil then
		return true
	else
		return false
	end
end

local function MergeRankLists(rankKey, serverList, localList)
	local updateCache = UpdateRankCache[rankKey]
	local combinedMap = {}
	for _, data in ipairs(serverList) do
		combinedMap[data.PlayerID] = data
	end
	for _, data in ipairs(localList) do
		if updateCache and updateCache[data.PlayerID] then
			local existing = combinedMap[data.PlayerID]
			if existing then
				if data.Value > existing.Value then
					combinedMap[data.PlayerID] = data
				end		
			else
				combinedMap[data.PlayerID] = data
			end
		end
	end

	local combined = {}
	for _, data in pairs(combinedMap) do
		combined[#combined+1] = data
	end

	combined = Util:ListSort(combined, {
		function(data) return -data.Value end,
		function(data) return data.PlayerID end,
	})
	combined = Util:ListSelectStart(combined, 100)

	for i, data in ipairs(combined) do
		data.Rank = i
	end
	
	return combined
end

function GameRank:Init()
	PlayerManager:HandlePlayerAddRemove(function(player)
		
	end, function(player)
		
	end)
	
	task.spawn(function()
		LastUpdateTime = os.time()
		while true do
			task.wait(10)
			if os.time() - LastUpdateTime >= UpdateInterval then
				local success = GameRank:ForceUpdateRank(true)
				LastUpdateTime = os.time()
				if success then
					UpdateInterval = Define.Data.GameRankSaveInterval
				else
					UpdateInterval = Define.Data.GameRankSaveInterval * 1.5
				end
				
			end		
		end
	end)

	game:BindToClose(function()
		--if RunService:IsStudio() then return end
		task.spawn(function()
			GameRank:ForceUpdateRank(false)
		end)
	end)
end

function GameRank:GetDataStoreKey(rankKey)
	local dataStoreName = "GameRank"
	return dataStoreName
end

function GameRank:GetDataModuleKey(rankKey)
	local dataStoreName = "RankList_"..rankKey
	return dataStoreName
end

function GameRank:ForceUpdateRank(waitNext)
	for _, rankKey in pairs(Define.RankList) do		
		local requireSave = false
		local dataStoreName = GameRank:GetDataStoreKey(rankKey)
		local dataModuleKey = GameRank:GetDataModuleKey(rankKey)
		ServerPrefs:ClearModuleCache(dataStoreName, dataModuleKey)
		local result = ServerPrefs:LoadFromDataStore(dataStoreName, dataModuleKey)
		if not result.Success then 
			return false
		end
		
		local serverList = ServerPrefs:GetValue(dataStoreName, dataModuleKey, "RankList")
		if not serverList then serverList = {} end
		local localList = GameRank:GetRankList(rankKey)
		local needMerge = CheckNeedMerge(serverList, localList)
		if needMerge then
			local merged = MergeRankLists(rankKey, serverList, localList)
			ServerPrefs:SetValue(dataStoreName, dataModuleKey, "RankList", merged)
			GameRankCache[rankKey] = merged

			requireSave = CheckNeedUpdate(rankKey)
			if requireSave then
				ServerPrefs:SaveToDataStore(dataStoreName, dataModuleKey, function(success)
					LogUtil:Log("[Server] Save RankList : ", rankKey, success)
				end)
			end
			
			EventManager:DispatchToAllClient(EventManager.Define.RefreshRank, { RankKey = rankKey })
		end
		
		UpdateRankCache[rankKey] = {}

		if waitNext then
			task.wait(10)
		else
			task.wait(1)
		end
		
		
	end	
	
	return true
end

function GameRank:GetRankList(rankKey)
	local result = GameRankCache[rankKey]
	if not result then
		local dataStoreName = GameRank:GetDataStoreKey(rankKey)
		local dataModuleKey = GameRank:GetDataModuleKey(rankKey)
		local rankList = ServerPrefs:GetValue(dataStoreName, dataModuleKey, "RankList")
		if not rankList then
			rankList = {}
		end

		result = Util:TableCopy(rankList)
		GameRankCache[rankKey] = result
	end

	return result
end

function GameRank:SetRank(player, rankKey, value)
	if not player then return end
	local userID = player.UserId
	local userName = player.Name
	task.spawn(function()
		local rankList = GameRank:GetRankList(rankKey)

		local createNewRank = false
		value = math.round(value)

		if #rankList < 100 then
			createNewRank = true
		else
			local lastData = rankList[#rankList]
			if value > lastData.Value then
				createNewRank = true
			end
		end

		if not createNewRank then
			return
		end

		local rankData = {
			Rank = 99999,
			PlayerID = userID,
			Name = userName,
			Value = value,
			Time = Util:GetDateStr(),
		}

		Util:ListRemoveWithCondition(rankList, function(data) return data.PlayerID == userID end)
		table.insert(rankList, rankData)
		
		rankList = Util:ListSort(rankList, {
			function(data) return -data.Value end,
			function(data) return data.PlayerID end,
		})

		rankList = Util:ListSelectStart(rankList, 100)
		for index, data in ipairs(rankList) do
			data.Rank = index
		end
		
		if not UpdateRankCache[rankKey] then
			UpdateRankCache[rankKey] = {}
		end
		
		UpdateRankCache[rankKey][userID] = true
		
		GameRankCache[rankKey] = rankList
		EventManager:DispatchToAllClient(EventManager.Define.RefreshRank, { RankKey = rankKey })
	end)
end

return GameRank
