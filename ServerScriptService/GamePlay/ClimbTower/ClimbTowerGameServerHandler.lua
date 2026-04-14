local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local SceneManager = require(game.ReplicatedStorage.ScriptAlias.SceneManager)
local SceneAreaManager = require(game.ReplicatedStorage.ScriptAlias.SceneAreaManager)

local SceneAreaServerHandler = require(game.ServerScriptService.ScriptAlias.SceneAreaServerHandler)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)
local ClimbTowerRequest = require(game.ServerScriptService.ScriptAlias.ClimbTower)
local PlayerProperty = require(game.ServerScriptService.ScriptAlias.PlayerProperty)
local PartnerServerHandler = require(game.ServerScriptService.ScriptAlias.PartnerServerHandler)

local ClimbTowerServerHandler = require(game.ServerScriptService.ScriptAlias.ClimbTowerServerHandler)
local ClimbTowerDefine = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerDefine)

local Define = require(game.ReplicatedStorage.Define)

local ClimbTowerGameServerHandler = {}

local PlayerCache = {}

function ClimbTowerGameServerHandler:Init()
	PlayerCache = {}
	
	PlayerManager:HandleCharacterAddRemove(function(player, character)
		ClimbTowerGameServerHandler:OnPlayerAdded(player, character)
	end, function(player, character)
		ClimbTowerGameServerHandler:OnPlayerRemoved(player, character)
	end)
	
	UpdatorManager:Heartbeat(function(deltaTime)
		ClimbTowerGameServerHandler:Update(deltaTime)
	end)
end

function ClimbTowerGameServerHandler:OnPlayerAdded(player, character)
	--PlayerManager:HandleStateChanged(player, function(oldState, newState)
	--	ClimbTowerGameServerHandler:OnStateChanged(player, oldState, newState)
	--end)
end

function ClimbTowerGameServerHandler:OnPlayerRemoved(player, character)
	local playerInfo = PlayerCache[player]
	if not playerInfo then return end
	PlayerCache[player] = nil
end

function ClimbTowerGameServerHandler:GetPlayerCache()
	return PlayerCache
end

--function ClimbTowerGameServerHandler:OnStateChanged(player, oldState, newState)
--	local playerInfo = PlayerCache[player]
--	if not playerInfo then return end

--end

function ClimbTowerGameServerHandler:GetPlayerDistance(player)
	local result = PlayerManager:GetHeight(player) + ClimbTowerDefine.Game.GroundHeightOffset
	return result
end

function ClimbTowerGameServerHandler:GetTowerLength(player)
	local areaInfo = SceneAreaServerHandler:GetAreaByPlayer(player)
	if areaInfo then
		local top = areaInfo.Area.Game.Tower.Top
		local height = top.Position.Y
		return height
	else
		return 0
	end
end	

function ClimbTowerGameServerHandler:Update(deltaTime)
	local playerCache = table.clone(PlayerCache)
	for player, playerInfo in pairs(playerCache) do
		playerInfo.CurrentDistance = ClimbTowerGameServerHandler:GetPlayerDistance(player)
		if playerInfo.CurrentDistance > playerInfo.ArriveDistance then
			playerInfo.ArriveDistance = playerInfo.CurrentDistance
		end
	end
	
	local brocadcastInfo = {}
	
	local onlinePlayerList = game.Players:GetPlayers()
	for index, player in ipairs(onlinePlayerList) do
		local playerID = player.UserId
		local playerInfo = playerCache[player]
		if playerInfo then
			local distance = math.round(playerInfo.CurrentDistance)
			--if playerInfo.RequireRefresh then
			--	playerInfo.Length = ClimbTowerGameServerHandler:GetTowerLength(player)
			--end
			
			local length = math.round(playerInfo.Length)
			local progress = math.clamp(distance / length, 0, 1)
			local info = {
				PlayerID = playerID,
				Distance = distance,
				Progress = progress,
				Length = length,
			}

			table.insert(brocadcastInfo, info)
		else
			local info = {
				PlayerID = playerID,
				Distance = 0,
				Progress = 0,
				Length = 0,
			}

			table.insert(brocadcastInfo, info)
		end
	end
	
	NetServer:BroadcastAll("ClimbTower", "UpdateGameInfo", brocadcastInfo)
end

function ClimbTowerGameServerHandler:KickAllPlayers(towerIndex)
	local infoList = table.clone(PlayerCache)
	for player, playerInfo in pairs(infoList) do
		if playerInfo.TowerIndex == towerIndex then
			ClimbTowerGameServerHandler:Exit(player)
			ClimbTowerGameServerHandler:ResetToTower(player)
		end
	end
end

function ClimbTowerGameServerHandler:Enter(player, param)
	local towerInfo = ClimbTowerServerHandler:GetTowerByIndex(param.Index)
	if towerInfo.Player == nil then
		return false
	end
	
	local gameInitParam = {
		TowerIndex = param.Index,
	}
	
	local themeKey = towerInfo.ThemeKey
	local themeInfo = ClimbTowerRequest:GetThemeInfo(towerInfo.Player, { ThemeKey = themeKey })
	local themeData = ConfigManager:SearchData("Theme", "ThemeKey", themeKey)
	--local towerData = ConfigManager:GetData("Tower"..themeKey, gameThemeInfo.TowerLevel)
	gameInitParam.ThemeKey = themeKey
	--gameInitParam.TowerLevel = gameThemeInfo.TowerLevel
	local speed = PlayerProperty:GetGamePropertyValue(player, PlayerProperty.Define.SPEED)
	local maxSpeedFactor = PlayerProperty:GetGamePropertyValue(player, PlayerProperty.Define.MAX_SPEED_FACTOR)
	gameInitParam.Speed = speed * themeData.SpeedFactor * maxSpeedFactor 
	--gameInitParam.TowerLength = towerData.Length
	
	local getCoinFactor = PlayerProperty:GetGamePropertyValue(player, PlayerProperty.Define.GET_COIN_FACTOR)
	local rewardCoinPerMeter = themeData.RewardCoin
	gameInitParam.RewardCoinPerMeter = rewardCoinPerMeter
	gameInitParam.GetCoinFactor = getCoinFactor
	
	local toolRequest = require(game.ServerScriptService.ScriptAlias.Tool)
	local toolInfo = toolRequest:GetEquip(player)
	local toolData = ConfigManager:GetData("Tool", toolInfo.ID)
	--local moveHeight = toolData.GameHeight
	--gameInitParam.MoveHeight = moveHeight
	
	local towerDataList = ConfigManager:GetDataList("Tower"..themeKey)
	gameInitParam.IsTowerMaxLevel = themeInfo.TowerHeight >= themeData.Length
	
	local playerInfo = {
		Player = player,
		TowerIndex = param.Index,
		ThemeKey = themeKey,
		GetCoinFactor = getCoinFactor,
		--TowerLevel = gameThemeInfo.TowerLevel,
		TowerInfo = towerInfo,
		Length = themeData.Length,
		ThemeInfo = themeInfo,
		ThemeData = themeData,
		ArriveDistance = 0,
		CurrentDistance = 0,
		IsGetWins = false,
		RewardCoinPerMeter = rewardCoinPerMeter,
		MoveSpeed = gameInitParam.Speed,
		GamePhase = ClimbTowerDefine.GamePhase.Up,
		--RequireRefresh = false,
	}
	
	local humanoid = PlayerManager:GetHumanoid(player)
	humanoid.WalkSpeed = gameInitParam.Speed
	if humanoid.WalkSpeed > ClimbTowerDefine.Game.MaxClimbSpeed then
		humanoid.WalkSpeed = ClimbTowerDefine.Game.MaxClimbSpeed
	end

	PlayerCache[player] = playerInfo
	
	PartnerServerHandler:SetOffset(player, ClimbTowerDefine.Game.PartnerGameOffset)
	
	EventManager:DispatchToClient(player, ClimbTowerDefine.Event.Enter, gameInitParam)
	return true
end

--function ClimbTowerGameServerHandler:ArriveEnd(player)
--	local playerInfo = PlayerCache[player]
--	if not playerInfo then return false end
--	playerInfo.GamePhase = ClimbTowerDefine.GamePhase.ArriveEnd
	
--	local humanoid = PlayerManager:GetHumanoid(player)
--	humanoid.WalkSpeed = Define.Game.WalkSpeed
	
--	EventManager:DispatchToClient(player, ClimbTowerDefine.Event.ArriveEnd)
--	return true
--end

function ClimbTowerGameServerHandler:Slide(player, param)
	local playerInfo = PlayerCache[player]
	if not playerInfo then return false end
	
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	--playerInfo.ArriveDistance = ClimbTowerGameServerHandler:GetPlayerDistance(player)
	--print(playerInfo.ArriveDistance)
	playerInfo.MoveSpeed = 0
	playerInfo.GamePhase = ClimbTowerDefine.GamePhase.Down
	
	EventManager:DispatchToClient(player, ClimbTowerDefine.Event.Slide)
	return true
end

function ClimbTowerGameServerHandler:Exit(player)
	local playerInfo = PlayerCache[player]
	if not playerInfo then return false end
	
	playerInfo.GamePhase = ClimbTowerDefine.GamePhase.Idle
	PlayerCache[player] = nil
	
	local humanoid = PlayerManager:GetHumanoid(player)
	humanoid.WalkSpeed = Define.Game.WalkSpeed

	PartnerServerHandler:SetOffset(player, ClimbTowerDefine.Game.PartnerIdleOffset)

	EventManager:DispatchToClient(player, ClimbTowerDefine.Event.Exit)
	return true
end

function ClimbTowerGameServerHandler:GetWins(player)
	local playerInfo = PlayerCache[player]
	if not playerInfo then return false end
	--if playerInfo.GamePhase ~= ClimbTowerDefine.GamePhase.ArriveEnd then return false end
	if playerInfo.IsGetWins then return false end
	
	local getWinsFactor = PlayerProperty:GetGamePropertyValue(player, PlayerProperty.Define.GET_WINS_FACTOR)
	local value = playerInfo.ThemeData.RewardWins * getWinsFactor
	local accountRequest = require(game.ServerScriptService.ScriptAlias.Account)
	accountRequest:AddWins(player, { Value = value })
	playerInfo.IsGetWins = true
	return true
end

function ClimbTowerGameServerHandler:GetCoin(player)
	local playerInfo = PlayerCache[player]
	if not playerInfo then return false end
	
	--print(playerInfo, playerInfo.RewardCoinPerMeter, playerInfo.ArriveDistance)
	local getCoinFactor = PlayerProperty:GetGamePropertyValue(player, PlayerProperty.Define.GET_COIN_FACTOR)
	local value = math.round(playerInfo.RewardCoinPerMeter * playerInfo.ArriveDistance * getCoinFactor)
	local accountRequest = require(game.ServerScriptService.ScriptAlias.Account)
	
	--warn(playerInfo.RewardCoinPerMeter, playerInfo.ArriveDistance, value, getCoinFactor)
	
	accountRequest:AddCoin(player, { Value = value })
	return true
end

function ClimbTowerGameServerHandler:ResetToDigArea(player)
	local part = SceneManager.LevelRoot.Game.DigAreaPos
	PlayerManager:SetCFrameToPart(player, part, 10)
end

function ClimbTowerGameServerHandler:ResetToTower(player)
	local areaInfo = SceneAreaServerHandler:GetAreaByPlayer(player)
	if areaInfo then
		PlayerManager:SetCFrameToPart(player, areaInfo.Area.Game.ClimbTowerPos)
	end
end

return ClimbTowerGameServerHandler
