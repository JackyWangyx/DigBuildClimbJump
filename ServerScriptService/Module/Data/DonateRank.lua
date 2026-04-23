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

local DonateRank = {}

DonateRank.CurrentWeeklyKey = nil

function DonateRank:Init()
	DonateRank.CurrentWeeklyKey = DonateRank:GetWeeklyKey()
end

---------------------------------------------------------------------------------------------------
-- Info

function DonateRank:GetWeeklyKey()
	local key = "WeeklyDonate_" .. TimeUtil:GetCurrentWeeklyKey(true)
	
	local needInit = false
	if DonateRank.CurrentWeeklyKey == nil then
		DonateRank.CurrentWeeklyKey = key
	end
	
	-- 刚启动，为空
	if not Define.RankList[key] then
		needInit = true
	end
	
	-- 周发生变化
	if DonateRank.CurrentWeeklyKey and DonateRank.CurrentWeeklyKey ~= key then
		Define.RankList[DonateRank.CurrentWeeklyKey] = nil
		Define.PlayerRecord[DonateRank.CurrentWeeklyKey] = nil
		needInit = true
	end

	if needInit then
		Define.RankList[key] = key
		Define.PlayerRecord[key] = key
		
		DonateRank.CurrentWeeklyKey = key
	end
	
	return key
end

---------------------------------------------------------------------------------------------------
-- Func

function DonateRank:Donate(player, level)
	local config = ConfigManager:SearchData("IAP", "ProductKey", "Donate" .. level)
	local value = config.CostRobux
	
	-- Total
	PlayerRecord:AddValue(player, Define.PlayerRecord.TotalDonate, value)
	
	-- Weekly
	local weeklyKey = DonateRank:GetWeeklyKey()
	PlayerRecord:AddValue(player, weeklyKey, value)
	
	return true
end

return DonateRank
