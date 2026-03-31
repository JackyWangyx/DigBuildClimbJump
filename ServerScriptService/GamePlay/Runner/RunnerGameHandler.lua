local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local SceneManager = require(game.ReplicatedStorage.ScriptAlias.SceneManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)
local RobloxUtil = require(game.ReplicatedStorage.ScriptAlias.RobloxUtil)

local PlayerProperty = require(game.ServerScriptService.ScriptAlias.PlayerProperty)
local PlayerStatus = require(game.ServerScriptService.ScriptAlias.PlayerStatus)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)
local RunnerGameSlotManager = require(game.ServerScriptService.ScriptAlias.RunnerGameSlotManager)
local RunnerGameLoopManager = require(game.ServerScriptService.ScriptAlias.RunnerGameLoopManager)

local Define = require(game.ReplicatedStorage.Define)

local RunnerGameHandler = {}

RunnerGameHandler.MineList = {}
RunnerGameHandler.MineCount = 0
RunnerGameHandler.GameInfo = {
	GamePhase = Define.GamePhase.Ready,
	GameTimer = 0,
}

RunnerGameHandler.PlayerList = {}
RunnerGameHandler.ServerPlayerList = {}

function RunnerGameHandler:Init()
	PlayerManager:HandleCharacterAddRemove(function(player, character)
		
	end, function(player, character)
		if RunnerGameSlotManager:IsPlayerInSlot(player) then
			RunnerGameHandler:PlayerLeave(player)
		end
	end)
	
	task.wait(1)
	RunnerGameHandler:GameInit()
end

function RunnerGameHandler:GameInit()
	RunnerGameHandler.GameInfo = {
		GamePhase = Define.GamePhase.Ready,
		GameTimer = 0,
	}
	
	RunnerGameHandler.PlayerList = {}
	RunnerGameHandler.ServerPlayerList = {}

	-- 初始化砖块数据
	RunnerGameHandler.MineList = {}
	local miningTrackDataList = ConfigManager:GetDataList("MiningTrack")
	for _, trackData in ipairs(miningTrackDataList) do
		for i = trackData.Start, trackData.End do
			local data = {
				Index = i,
				Data = trackData,
			}

			table.insert(RunnerGameHandler.MineList, data)
		end
	end
	
	RunnerGameHandler.MineCount = #RunnerGameHandler.MineList

	-- Init Track & Slot
	RunnerGameSlotManager:Init(Define.Game.TrackCount)
	local trackRoot = SceneManager.LevelRoot.Game:WaitForChild("Track")
	for index, slotInfo in ipairs(RunnerGameSlotManager.SlotList) do
		local trackPart = trackRoot:WaitForChild("Track_"..string.format("%02d", index))
		local trackInfo = {
			Index = index,
			StartPos = Vector3.new(trackPart.Position.X, PlayerManager.DefaultMoveHeight, trackPart.Position.Z),
		}
		
		slotInfo.TrackInfo = trackInfo
	end
	
	-- Init Game Loop
	RunnerGameLoopManager:Init(self)
	RunnerGameLoopManager:Start()
end

function RunnerGameHandler:GetPhase()
	return RunnerGameHandler.GameInfo.GamePhase
end

function RunnerGameHandler:Clear()
	for playerID, playerInfo in pairs(RunnerGameHandler.PlayerList) do
		RunnerGameHandler.PlayerList[playerID] = nil
	end
	for playerID, playerInfo in pairs(RunnerGameHandler.ServerPlayerList) do
		RunnerGameHandler.ServerPlayerList[playerID] = nil
	end

	RunnerGameSlotManager:Clear()
end

---------------------------------------------------------------------------------------------------------------------

-- Player Ready / Start / Enter / Leave

function RunnerGameHandler:PlayerEnter(player)
	if not player or not player.Parent then return false end
	
	local isComplete = false
	local enterSuccess = nil
	local enterSlotInfo = nil
	RunnerGameSlotManager:Enter(player, function(success, slot)
		isComplete = true
		enterSuccess = success
		enterSlotInfo = slot
	end)
	
	while not isComplete do
		task.wait()
	end
	
	if not enterSuccess then 
		return false 
	end
	
	local trackInfo = enterSlotInfo.TrackInfo

	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	if rootPart then
		rootPart:SetNetworkOwner(player)
		local s = rootPart:GetNetworkOwner()
	end

	PlayerManager:DisablePhysic(player)
	
	local power = PlayerProperty:GetPower(player)
	local maxSpeedBase = PlayerProperty:GetMaxSpeedByPower(player, power)
	local speedFactor = PlayerProperty:GetGamePropertyValue(player, PlayerProperty.Define.MAX_SPEED_FACTOR)
	local maxSpeed = maxSpeedBase * speedFactor
	local startSpeed = maxSpeed * 0.1
	local acceleration = PlayerProperty:GetGamePropertyValue(player, PlayerProperty.Define.ACCELERATION)
	local getCoinFactor = PlayerProperty:GetGamePropertyValue(player, PlayerProperty.Define.GET_COIN_FACTOR)
	maxSpeed = Util:RoundFloat(maxSpeed, 2)
	startSpeed = Util:RoundFloat(startSpeed, 2)
	acceleration = Util:RoundFloat(acceleration, 2)

	local startPos = Vector3.new(trackInfo.StartPos.X, trackInfo.StartPos.Y + 1.5, trackInfo.StartPos.Z + 1)
	local playerInfo = {
		TrackIndex = trackInfo.Index,
		StartPos = startPos,
		Distance = 0,
		ToolWorkDistance = 1,
		CurrentSpeed = maxSpeed * 0.1, -- 0
		RewardCoin = 0,
		Power = power,
		StartSpeed = startSpeed,	
		MaxSpeed = maxSpeed,
		Acceleration = acceleration,
	}

	local serverPlayerInfo = {
		LastMineDataIndex = 1,	
		LastMineIndex = 1,
		ToolID = -1,
		GetCoinFactor = getCoinFactor,
	}

	local equipToolInfo = NetServer:RequireModule("Tool"):GetEquip(player)
	if equipToolInfo then
		local equipToolID = equipToolInfo.ID
		local equipToolData = ConfigManager:GetData("Tool", equipToolID)
		if equipToolData then
			local startPos = Vector3.new(trackInfo.StartPos.X, equipToolData.GameHeight, trackInfo.StartPos.Z + equipToolData.WorkDistance)
			playerInfo.StartPos = startPos
			playerInfo.ToolWorkDistance = equipToolData.WorkDistance
			serverPlayerInfo.ToolID = equipToolID
		end
	end

	RunnerGameHandler.PlayerList[player.UserId] = playerInfo
	RunnerGameHandler.ServerPlayerList[player.UserId] = serverPlayerInfo
	RunnerGameHandler:SetPlayerReady(player)
	
	NetServer:Broadcast(player, "Game", "OnEnter")
	EventManager:DispatchToClient(player, EventManager.Define.GameEnter)
	
	if RunnerGameHandler.GameInfo.GamePhase == Define.GamePhase.Gaming then
		RunnerGameHandler:PlayerStart(player)
	end

	return true
end

function RunnerGameHandler:PlayerLeave(player)
	if not player or not player.Parent then return false end
	
	local isComplete = false
	local leaveSuccess = nil
	local leaveSlotInfo = nil
	RunnerGameSlotManager:Leave(player, function(success, slot)
		isComplete = true
		leaveSuccess = success
		leaveSlotInfo = slot
	end)

	while not isComplete do
		task.wait()
	end
	
	if not leaveSuccess then 
		return false
	end
	
	--local trackInfo = leaveSlotInfo.TrackInfo
	local serverPlayerInfo = RunnerGameHandler.ServerPlayerList[player.UserId]
	if serverPlayerInfo then
		if serverPlayerInfo.ToolID > 0 then
			local equipToolData = ConfigManager:GetData("Tool", serverPlayerInfo.ToolID)
			PlayerManager:StopAnimation(player, equipToolData.GameAnimation)
			PlayerManager:PlayAnimation(player, equipToolData.RunAnimation, true, 1)
		end
	end
	
	PlayerManager:EnablePhysic(player)
	--PlayerManager:DisableControl(player)
	
	RunnerGameHandler.PlayerList[player.UserId] = nil
	RunnerGameHandler.ServerPlayerList[player.UserId] = nil
	NetServer:Broadcast(player, "Game", "OnLeave")
	EventManager:DispatchToClient(player, EventManager.Define.GameLeave)
	PlayerStatus:SetStatus(player, PlayerStatus.Define.Idle)
	
	return true
end

function RunnerGameHandler:SetPlayerReady(player)
	if not player or not player.Parent then return false end
	local playerInfo = RunnerGameHandler.PlayerList[player.UserId]
	if not playerInfo then 
		return 
	end
	
	local serverPlayerInfo = RunnerGameHandler.ServerPlayerList[player.UserId]

	playerInfo.Distance = 0
	playerInfo.CurrentSpeed = playerInfo.MaxSpeed * 0.1
	playerInfo.RewardCoin = 0
	
	serverPlayerInfo.StartTime = os.time()
	serverPlayerInfo.LastMineDataIndex = 1
	serverPlayerInfo.LastMineIndex = 1
	
	if serverPlayerInfo.ToolID > 0 then
		local equipToolData = ConfigManager:GetData("Tool", serverPlayerInfo.ToolID)
		PlayerManager:StopAnimation(player, equipToolData.GameAnimation)
		PlayerManager:PlayAnimation(player, equipToolData.RunAnimation, true, 1)
	end
	
	PlayerStatus:SetStatus(player, PlayerStatus.Define.GameReady)
end

function RunnerGameHandler:PlayerStart(player)
	if not player or not player.Parent then return false end
	local playerInfo = RunnerGameHandler.PlayerList[player.UserId]
	if not playerInfo then return end
	
	local serverPlayerInfo = RunnerGameHandler.ServerPlayerList[player.UserId]
	
	NetServer:Broadcast(player, "Game", "OnStart")
	if serverPlayerInfo.ToolID > 0 then
		local equipToolData = ConfigManager:GetData("Tool", serverPlayerInfo.ToolID)
		PlayerManager:StopAnimation(player, equipToolData.RunAnimation)
		PlayerManager:PlayAnimation(player, equipToolData.GameAnimation, true, 1)
	end
	
	PlayerStatus:SetStatus(player, PlayerStatus.Define.Gaming)
	EventManager:DispatchToClient(player, EventManager.Define.GameStart)
	AnalyticsManager:Event(player, AnalyticsManager.Define.PlayGame)
end

---------------------------------------------------------------------------------------------------------------------

-- 游戏主循环出错后的补偿处理
function RunnerGameHandler:HandleGameCrash(err)
	warn("[Server] Game Loop Crash Start : ",  RobloxUtil:GetRoomID(), debug.traceback(err, 2))
	
	-- 踢出所有玩家
	local playerList = table.clone(RunnerGameHandler.PlayerList)
	for playerID, playerInfo in pairs(playerList) do
		local player = PlayerManager:GetPlayerById(playerID)
		if not player then continue end
		if RunnerGameSlotManager:IsPlayerInSlot(player) then
			RunnerGameHandler:PlayerLeave(player)
		end
	end
	
	NetServer:BroadcastAll("Game", "OnFinish")
	-- 初始化游戏
	RunnerGameHandler:GameInit()
	
	warn("[Server] Game Loop Crash Complete : ", RobloxUtil:GetRoomID(), debug.traceback(err, 2))
end

return RunnerGameHandler