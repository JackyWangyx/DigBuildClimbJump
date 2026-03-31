local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local BigNumber = require(game.ReplicatedStorage.ScriptAlias.BigNumber)

local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)
local PlayerProperty = require(game.ServerScriptService.ScriptAlias.PlayerProperty)

local Define = require(game.ReplicatedStorage.Define)

local PlayerLeaderStats = {}

local LeaderStatsCache = {}

function PlayerLeaderStats:Init()
	PlayerManager:HandlePlayerAddRemove(function(player)
		PlayerLeaderStats:OnPlayerAdded(player)
	end, function(player)
		PlayerLeaderStats:OnPlayerRemoved(player)
	end)
	
	UpdatorManager:Heartbeat(function(deltaTime)
		PlayerLeaderStats:Update(deltaTime)
	end)
end

function PlayerLeaderStats:InitPlayerValue(player)
	PlayerLeaderStats:RegisterValue(player, "🏆 Wins", function()
		local value = NetServer:RequireModule("Account"):GetWins(player)
		--local text = BigNumber:Format(value)
		return value
	end)
	
	PlayerLeaderStats:RegisterValue(player, "💰 Coin", function()
		local value = NetServer:RequireModule("Account"):GetCoin(player)
		--local text = BigNumber:Format(value)
		return value
	end)
	
	--PlayerLeaderStats:RegisterValue(player, "⚡ Power", function()
	--	local value =  PlayerProperty:GetPower(player)
	--	--local text = BigNumber:Format(value)
	--	return value
	--end)
	
	--PlayerLeaderStats:RegisterValue(player, "👆 Click", function()
	--	local value =  NetServer:RequireModule("Record"):GetValue(player, { Key = Define.PlayerRecord.TotalClick })
	--	--local text = BigNumber:Format(value)
	--	return value
	--end)
	
	--PlayerLeaderStats:RegisterValue(player, "🔄 Rebirth", function()
	--	local value =  NetServer:RequireModule("Rebirth"):GetInfo(player).ID - 1
	--	--local text = BigNumber:Format(value)
	--	return value
	--end)
end

function PlayerLeaderStats:OnPlayerAdded(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	local info = {
		Player = player,
		LeaderStats = leaderstats,
		ValueList = {},
	}
	
	LeaderStatsCache[player] = info
	task.defer(function()
		PlayerLeaderStats:InitPlayerValue(player)
	end)
end

function PlayerLeaderStats:OnPlayerRemoved(player)
	LeaderStatsCache[player] = nil
end

function PlayerLeaderStats:RegisterValue(player, valueName, valueGetter)
	local info = LeaderStatsCache[player]
	if not info then return end
	
	local valueInstance = Instance.new("IntValue")
	valueInstance.Name = valueName
	valueInstance.Value = valueGetter()
	valueInstance.Parent = info.LeaderStats
	
	local valueInfo = {
		Name = valueName,
		Instance = valueInstance,
		Getter = valueGetter,
	}
	
	table.insert(info.ValueList, valueInfo)
	PlayerLeaderStats:Refresh(player)
end

function PlayerLeaderStats:Refresh(player)
	local info = LeaderStatsCache[player]
	if not info then return end
	for _, valueInfo in ipairs(info.ValueList) do
		local success, err = pcall(function()
			local valueInstance = valueInfo.Instance
			valueInstance.Value = valueInfo.Getter()
		end)
		
		if not success then
			warn("[PlayerLeaderStats]", player.UserId, valueInfo.Name, err)
		end
	end
end

function PlayerLeaderStats:RefreshAll()
	local playerList = game.Players:GetPlayers()
	for _, player in ipairs(playerList) do
		PlayerLeaderStats:Refresh(player)
	end
end

local LastUpdateTime = 0
local RefreshInteval = 5.1

function PlayerLeaderStats:Update(deltaTime)
	local currentTime = tick()
	if currentTime - LastUpdateTime >= RefreshInteval then
		LastUpdateTime = currentTime
		PlayerLeaderStats:RefreshAll()
	end
end

return PlayerLeaderStats
