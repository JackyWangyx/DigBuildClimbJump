local RunService = game:GetService("RunService")

local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local PlayerCache = require(game.ServerScriptService.ScriptAlias.PlayerCache)
local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local GameRank = require(game.ServerScriptService.ScriptAlias.GameRank)

local Define = require(game.ReplicatedStorage.Define)

local PlayerRecord = {}

PlayerRecord.DATA_MODULE_KEY = "PlayerRecord"
PlayerRecord.Define = require(game.ReplicatedStorage.Define).PlayerRecord

function PlayerRecord:Init()
	RunService.Heartbeat:Connect(function(deltaTime)
		PlayerRecord:Update(deltaTime)
	end)
end

function PlayerRecord:Update(deltaTime)
	local playerList = game.Players:GetPlayers()
	for _, player in ipairs(playerList) do
		local saveRecord = PlayerRecord:GetRecord(player)
		if not saveRecord then return end
		local value = saveRecord[PlayerRecord.Define.TotalOnlineTime]
		if not value then
			value = deltaTime
		else
			value += deltaTime
		end
		
		saveRecord[PlayerRecord.Define.TotalOnlineTime] = value
	end
end

function PlayerRecord:GetRecord(player)
	local saveRecord = PlayerPrefs:GetModule(player, PlayerRecord.DATA_MODULE_KEY)
	return saveRecord
end

function PlayerRecord:GetValue(player, key)
	local saveRecord = PlayerPrefs:GetModule(player, PlayerRecord.DATA_MODULE_KEY)
	local value = saveRecord[key]
	if not value then
		return 0
	end
	return value
end

function PlayerRecord:AddValue(player, key, value)
	local saveRecord = PlayerPrefs:GetModule(player, PlayerRecord.DATA_MODULE_KEY)
	local currentValue = saveRecord[key]
	if not currentValue then
		currentValue = 0
	end
	
	local newValue = currentValue + value
	saveRecord[key] = newValue
	EventManager:DispatchToClient(player, Define.Event.RefreshRecord, { Key = key, Value = newValue })
	
	-- 更新排行榜
	if key == Define.PlayerRecord.TotalGetCoin then
		GameRank:SetRank(player, Define.RankList.TotalGetCoin, newValue)
	end
	
	if key == Define.PlayerRecord.TotalGetWins then
		GameRank:SetRank(player, Define.RankList.TotalGetWins, newValue)
	end
	
	if key == Define.PlayerRecord.TotalGetPower then
		GameRank:SetRank(player, Define.RankList.TotalGetPower, newValue)
	end
	
	if key == Define.PlayerRecord.TotalRebirth then
		GameRank:SetRank(player, Define.RankList.TotalRebirth, newValue)
	end
	
	if key == Define.PlayerRecord.TotalClick then
		GameRank:SetRank(player, Define.RankList.TotalClick, newValue)
	end
end

function PlayerRecord:SetMaxValue(player, key, value)
	local saveRecord = PlayerPrefs:GetModule(player, PlayerRecord.DATA_MODULE_KEY)
	local currentValue = saveRecord[key]
	if not currentValue then
		currentValue = 0
	end
	if value > currentValue then
		local addValue = value - currentValue
		PlayerRecord:AddValue(player, key, addValue)
	end
end

function PlayerRecord:SetMinValue(player, key, value)
	local saveRecord = PlayerPrefs:GetModule(player, PlayerRecord.DATA_MODULE_KEY)
	local currentValue = saveRecord[key]
	if not currentValue then
		currentValue = 0
	end
	if value < currentValue then
		saveRecord[key] = value
		EventManager:DispatchToClient(player, Define.Event.RefreshRecord, { Key = key, Value = value })
	end
end

return PlayerRecord
