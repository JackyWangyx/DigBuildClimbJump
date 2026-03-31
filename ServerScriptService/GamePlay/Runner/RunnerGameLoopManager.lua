local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local SceneManager = require(game.ReplicatedStorage.ScriptAlias.SceneManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local RunnerGameSlotManager = require(game.ServerScriptService.ScriptAlias.RunnerGameSlotManager)

local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local Define = require(game.ReplicatedStorage.Define)

local RunnerGameLoopManager = {}

RunnerGameLoopManager.IsRunning = false

local HeartbeatConnection = nil
local GameHandler = nil
local GameInfo = nil
local PlayerList = nil
local ServerPlayerList = nil

function RunnerGameLoopManager:Init(gameHandler)
	GameHandler = gameHandler
	GameInfo = GameHandler.GameInfo
	PlayerList = GameHandler.PlayerList
	ServerPlayerList = GameHandler.ServerPlayerList
	RunnerGameLoopManager.IsRunning = false
	
	if HeartbeatConnection then
		HeartbeatConnection:Disconnect()
	end
	
	HeartbeatConnection = UpdatorManager:Heartbeat(function(deltaTime)
		RunnerGameLoopManager:Update(deltaTime)
	end)
end

function RunnerGameLoopManager:Start()
	RunnerGameLoopManager.IsRunning = true
	RunnerGameLoopManager:CacheLevelObject()
	RunnerGameLoopManager:EnterReady()
end

function RunnerGameLoopManager:Stop()
	RunnerGameLoopManager.IsRunning = false
end

function RunnerGameLoopManager:Update(deltaTime)
	if not RunnerGameLoopManager.IsRunning then return end
	local success, err = pcall(function()
		RunnerGameLoopManager:UpdateImpl(deltaTime)
	end)

	if not success then
		GameHandler:HandleGameCrash(err)
	end	
end

local ServerGameTimer = 0
local LevelRoot = nil
local GameRoot = nil
local TrackRoot = nil
local StartRoot = nil
local TextCountDown = nil

function RunnerGameLoopManager:CacheLevelObject()
	LevelRoot = SceneManager.LevelRoot
	if LevelRoot then
		GameRoot = LevelRoot.Game
		if GameRoot then
			if not TrackRoot then
				TrackRoot = GameRoot:FindFirstChild("Track")
			end
			if not StartRoot then
				StartRoot = GameRoot:FindFirstChild("Start")
			else
				Util:ActiveObject(StartRoot)
			end
			if not TextCountDown then
				TextCountDown = Util:GetChildByName(GameRoot, "Text_CountDown")
			end	
		end
	end
end

function RunnerGameLoopManager:UpdateImpl(deltaTime)
	if not self.IsRunning then return end
	
	if GameState == "Ready" then
		GameState = "Countdown"
		if TextCountDown then TextCountDown.Text = tostring(CountdownTimer) end
		EventManager:DispatchToAllClient(EventManager.Define.GameStartNewLoop)
		NetServer:BroadcastAll("Game", "CountDown", { Value = CountdownTimer })

	elseif GameState == "Countdown" then
		CountdownTimer -= deltaTime
		local value = math.ceil(CountdownTimer)
		if TextCountDown then TextCountDown.Text = tostring(value) end
		if CountdownTimer <= 0 then
			if TextCountDown then TextCountDown.Text = "START!" end
			self:EnterStart()
		end

	elseif GameState == "Start" then
		ServerGameTimer += deltaTime
		if ServerGameTimer >= 1 then
			ServerGameTimer = 0
			self:EnterGaming()
		end

	elseif GameState == "Gaming" then
		local remain = Define.Game.GameTime - ServerGameTimer
		GameInfo.GameTimer = math.max(0, remain * 1000)
		self:UpdateGaming(deltaTime)
		
		if remain <= 0 then
			self:EnterFinish()
		end	
	elseif GameState == "Finish" then
		self:EnterReady()
	end
	
	RunnerGameLoopManager:BroadcastGameInfo(deltaTime)
end

function RunnerGameLoopManager:EnterReady()
	GameState = "Ready"

	GameInfo.GamePhase = Define.GamePhase.Ready
	GameInfo.GameTimer = Define.Game.GameTime * 1000
	ServerGameTimer = 0
	CountdownTimer = Define.Game.CountDown

	if StartRoot then Util:ActiveObject(StartRoot) end
end

function RunnerGameLoopManager:EnterStart()
	GameState = "Start"
	if StartRoot then Util:DeActiveObject(StartRoot) end
	GameInfo.GamePhase = Define.GamePhase.Start
	local playerList = table.clone(PlayerList)
	for playerID, playerInfo in pairs(playerList) do
		local player = PlayerManager:GetPlayerById(playerID)
		GameHandler:SetPlayerReady(player)
	end
end

function RunnerGameLoopManager:EnterGaming()
	GameState = "Gaming"
	GameInfo.GamePhase = Define.GamePhase.Gaming
	for playerID, playerInfo in pairs(PlayerList) do
		local player = PlayerManager:GetPlayerById(playerID)
		GameHandler:PlayerStart(player)
	end
end

function RunnerGameLoopManager:EnterFinish()
	GameState = "Finish"
	GameInfo.GamePhase = Define.GamePhase.Finish
	EventManager:DispatchToAllClient(EventManager.Define.GameFinish)
	local playerList = table.clone(PlayerList)
	for playerID, playerInfo in pairs(playerList) do
		local success, result = pcall(function()
			local player = PlayerManager:GetPlayerById(playerID)
			if player then
				GameHandler:PlayerLeave(player)

				PlayerRecord:AddValue(player, PlayerRecord.Define.TotalCompleteGame, 1)
				EventManager:Dispatch(EventManager.Define.QuestCompleteGame, {
					Player = player,
					Value = 1,
				})

				NetServer:Broadcast(player, "Game", "OnFinish")
			end	
		end)
		
		if not success then
			warn("[Game] Game Finish, Pleyer Leave Fail : ", debug.traceback(result, 3))
		end
	end
	
	GameHandler:Clear()
end

local UpdateFrame = 10
local UpdateInterval = 1 / UpdateFrame
local UpdateDeltaTime = 0
local LastUpdateTime = 0

function RunnerGameLoopManager:UpdateGaming(deltaTime)
	-- Game Update
	if GameInfo.GamePhase == Define.GamePhase.Gaming then
		if GameInfo.GameTimer > 0 then
			ServerGameTimer += deltaTime
			GameInfo.GameTimer = Define.Game.GameTime * 1000 - ServerGameTimer * 1000
			GameInfo.GameTimer = Util:RoundFloat(GameInfo.GameTimer, 3)
		end

		if ServerGameTimer >= Define.Game.GameTime then
			ServerGameTimer = Define.Game.GameTime
			GameInfo.GameTimer = 0
			GameInfo.GamePhase = Define.GamePhase.Finish
		end
	end

	-- Update Pos
	if GameInfo.GamePhase == Define.GamePhase.Gaming then
		for playerID, playerInfo in pairs(PlayerList) do
			local player = game.Players:GetPlayerByUserId(playerID)
			if not player then continue end
			if not playerInfo then continue end
			local serverPlayerInfo = ServerPlayerList[player.UserId]
			-- 加速度
			if playerInfo.CurrentSpeed < playerInfo.MaxSpeed then
				playerInfo.CurrentSpeed += playerInfo.Acceleration * deltaTime
				if playerInfo.CurrentSpeed > playerInfo.MaxSpeed then
					playerInfo.CurrentSpeed = playerInfo.MaxSpeed
				end
			end

			-- 移动
			playerInfo.Distance += playerInfo.CurrentSpeed * deltaTime
			playerInfo.CurrentSpeed = Util:RoundFloat(playerInfo.CurrentSpeed, 2)
			playerInfo.Distance = Util:RoundFloat(playerInfo.Distance, 3)

			-- 砖块
			local lastMineIndex = serverPlayerInfo.LastMineIndex
			local currentMineIndex = math.floor(playerInfo.Distance / Define.Game.MineSize)
			if currentMineIndex > GameHandler.MineCount then currentMineIndex = GameHandler.MineCount end
			if currentMineIndex >= lastMineIndex then
				local startIndex = lastMineIndex
				local endIndex = currentMineIndex
				RunnerGameLoopManager:UpdateBreakMine(player, startIndex, endIndex)
				serverPlayerInfo.LastMineIndex = currentMineIndex + 1
			end
			
			if playerInfo.Distance > Define.Game.MaxDistance then
				serverPlayerInfo.LastMineIndex = 1
				playerInfo.Distance = 0
				
				PlayerRecord:AddValue(player, PlayerRecord.Define.TotalArriveEnd, 1)
				EventManager:Dispatch(EventManager.Define.QuestArriveEnd, {
					Player = player,
					Value = 1,
				})

			end
		end
	end
end

function RunnerGameLoopManager:BroadcastGameInfo(deltaTime)
	-- 降低通信更新频率
	UpdateDeltaTime += deltaTime
	if UpdateDeltaTime >= UpdateInterval then
		UpdateDeltaTime -= UpdateInterval
	else
		return
	end

	-- 广播消息
	local sendInfo = {
		GameInfo = GameInfo,
		PlayerList = PlayerList,
	}
	
	NetServer:BroadcastAll("Game", "Update", sendInfo)
end

function RunnerGameLoopManager:UpdateBreakMine(player, startIndex, endIndex)
	if not player then return end
	local playerInfo = PlayerList[player.UserId]
	if not playerInfo then return end
	local serverPlayerInfo = GameHandler.ServerPlayerList[player.UserId]
	for mineIndex = startIndex, endIndex do
		local mineData = GameHandler.MineList[mineIndex].Data
		local isNext = serverPlayerInfo.LastMineDataIndex < mineData.ID
		local isEndLoop = mineIndex == Define.Game.MineCount
		if isNext or isEndLoop then
			local rewardCoin = GameHandler.MineList[mineIndex - 1].Data.RewardCoin
			local coin = math.round(rewardCoin * 1.0 * serverPlayerInfo.GetCoinFactor)
			playerInfo.RewardCoin += coin
			serverPlayerInfo.LastMineDataIndex = mineData.ID

			local equipToolData = ConfigManager:GetData("Tool", serverPlayerInfo.ToolID)
			PlayerManager:PlayAnimation(player, equipToolData.GameAnimation, true, mineData.AnimationSpeed)

			NetServer:Broadcast(player, "Game", "GetCoinReward")
			NetServer:RequireModule("Account"):AddCoin(player, { Value = coin })

			if isEndLoop then
				serverPlayerInfo.LastMineDataIndex = 1
				serverPlayerInfo.LastMineIndex = 1
			end

			continue
		end
	end
end

return RunnerGameLoopManager
