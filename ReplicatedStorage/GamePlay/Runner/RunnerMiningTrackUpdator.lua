local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local RunnerGameManager = require(game.ReplicatedStorage.ScriptAlias.RunnerGameManager)
local RunnerGameMineEffect = require(game.ReplicatedStorage.ScriptAlias.RunnerGameMineEffect)

local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local SoundManager = require(game.ReplicatedStorage.ScriptAlias.SoundManager)
local CompressUtil = require(game.ReplicatedStorage.ScriptAlias.CompressUtil)
local TaskManager = require(game.ReplicatedStorage.ScriptAlias.TaskManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local Define = require(game.ReplicatedStorage.Define)

local EnablePool = false

local RunnerMiningTrackUpdator = {}

local MiningTrackDataList = nil
local FxRoot = nil

local TrackPartList = {}
local UpdateRange = 50

local SelfTrackIndex = -1

-- Local
local CurrentDistance = 0
local CurrentSpeed = 0
local GameTimer = 0

-- Turn
local RangeLeft = -40      	-- 左移动最大偏移
local RangeRight = 40     	-- 右移动最大偏移
local TurnSpeed = 35      	-- 左右移动速度（建议调 4~10）

local LateralOffset = 0  	-- 当前左右偏移量缓存

-- On Broadcast
local GameInfo = {
	GamePhase = Define.GamePhase.Ready,
	GameTimer = 0,
}

local PlayerList = {}

local AlignPos = Instance.new("AlignPosition")
AlignPos.MaxForce = 1e8
AlignPos.Responsiveness = 200


function RunnerMiningTrackUpdator:Init()
	MiningTrackDataList = ConfigManager:GetDataList("MiningTrack")
	local trackRoot = RunnerGameManager.TrackRoot
	for trackIndex = 1, Define.Game.TrackCount do
		local trackPart = trackRoot:WaitForChild("Track_"..string.format("%02d", trackIndex))
		table.insert(TrackPartList, trackPart)
	end
	
	task.defer(function()
		UpdatorManager:Heartbeat(function(deltaTime)
			RunnerMiningTrackUpdator:Update(deltaTime)
		end)

		RunnerGameMineEffect:Init()
	end)
end

function RunnerMiningTrackUpdator:OnEnter(player)
	GameTimer = Define.Game.GameTime - GameInfo.GameTimer / 1000
	LateralOffset = 0
	RunnerMiningTrackUpdator:ResetPlayerPosCache()
	task.wait(0.2)
	
	RunnerMiningTrackUpdator:SetPlayerPosByDistance(player, 0)
	NetClient:Request("Tool", "GetEquip", function(toolInfo)
		if toolInfo then
			local toolData = ConfigManager:GetData("Tool", toolInfo.ID)
			RunnerGameMineEffect.ToolOffset = Vector3.new(toolData.EffectOffsetX, toolData.EffectOffsetY, toolData.EffectOffsetZ)
		end
	end)
end

function RunnerMiningTrackUpdator:OnStart(player)
	GameTimer = Define.Game.GameTime - GameInfo.GameTimer / 1000
	RunnerMiningTrackUpdator:ResetPlayerPosCache()
	task.wait(0.2)
	
	local playerInfo = RunnerMiningTrackUpdator:GetPlayerInfoByTrack(SelfTrackIndex)
	if playerInfo then
		CurrentSpeed = playerInfo.MaxSpeed * 0.1
	end
	
	RunnerMiningTrackUpdator:SetPlayerPosByDistance(player, 0)
	
	RunnerGameMineEffect:OnStart()
end

function RunnerMiningTrackUpdator:OnLeave(player)
	RunnerMiningTrackUpdator:ResetPlayerPosCache()
	
	PlayerManager:SetSpawnLocation(player)
	RunnerGameMineEffect:OnLeave()
end

function RunnerMiningTrackUpdator:OnFinish(player)
	RunnerMiningTrackUpdator:ResetPlayerPosCache()
	PlayerManager:SetSpawnLocation(player)
	
	RunnerGameMineEffect:OnFinish()
end

function RunnerMiningTrackUpdator:OnBoardcast(param)
	GameInfo = param.GameInfo
	PlayerList = param.PlayerList
	SelfTrackIndex = RunnerMiningTrackUpdator:GetSelfTrackIndex(game.Players.LocalPlayer)
end

function RunnerMiningTrackUpdator:Update(deltaTime)
	if not game.Players.LocalPlayer.Character then return end
	if GameInfo.GamePhase == Define.GamePhase.Gaming then
		if RunnerGameManager.IsGaming then
			RunnerMiningTrackUpdator:UpdatePlayerPosLocal(deltaTime)
		end
	end
end

function RunnerMiningTrackUpdator:GetSelfTrackIndex(player)
	local localPlayer = game.Players.LocalPlayer
	for _, info in pairs(PlayerList) do
		if info.ID == localPlayer.UserId then
			return info.TrackIndex
		end
	end

	return -1
end

function RunnerMiningTrackUpdator:GetPlayerInfoByTrack(trackIndex)
	for playerID, info in pairs(PlayerList) do
		if info.TrackIndex == trackIndex then
			return info
		end
	end
	return nil
end

function RunnerMiningTrackUpdator:GetPlayerInfoByID(userID)
	for playerID, info in pairs(PlayerList) do
		if tonumber(playerID) == userID then
			return info
		end
	end
	return nil
end

-------------------------------------------------------------------------------------------------------------------------

-- Player Pos - Local Test

function RunnerMiningTrackUpdator:ResetPlayerPosCache()
	CurrentDistance = 0
	CurrentSpeed = 0
	GameTimer = 0
end

function RunnerMiningTrackUpdator:GetPlayerPos(player)
	if not player then return Vector3.new(0,0,0) end
	local humanoidRootPart = PlayerManager:GetHumanoidRootPart(player)
	if not humanoidRootPart then return Vector3.new(0,0,0) end
	return humanoidRootPart.Position
end

function RunnerMiningTrackUpdator:GetPlayerPosByDistance(player, distance)
	if not player then return Vector3.new(0,0,0) end
	local playerInfo = RunnerMiningTrackUpdator:GetPlayerInfoByID(player.UserId)
	if playerInfo == nil then
		return RunnerMiningTrackUpdator:GetPlayerPos(player)
	end

	local startPos = playerInfo.StartPos
	local result = Vector3.new(startPos.X, startPos.Y, startPos.Z - distance + playerInfo.ToolWorkDistance)
	return result
end

function RunnerMiningTrackUpdator:SetPlayerPosByDistance(player, distance)	
	local pos = RunnerMiningTrackUpdator:GetPlayerPosByDistance(player, distance)
	RunnerMiningTrackUpdator:SetPlayerToPos(player, pos)
end

function RunnerMiningTrackUpdator:SetPlayerToPos(player, position)
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	if not rootPart then return end
	rootPart.CFrame = CFrame.new(position)
end

function RunnerMiningTrackUpdator:UpdatePlayerPosLocal(deltaTime)
	GameTimer += deltaTime

	local playerInfo = RunnerMiningTrackUpdator:GetPlayerInfoByTrack(SelfTrackIndex)
	if not playerInfo then return end

	local player = PlayerManager:GetPlayerById(playerInfo.ID)
	if not player then return end

	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	if not rootPart then return end

	local currentPos = RunnerMiningTrackUpdator:GetPlayerPos(player)
	-- 加速度
	if CurrentSpeed < playerInfo.MaxSpeed then
		CurrentSpeed += playerInfo.Acceleration * deltaTime
		if CurrentSpeed > playerInfo.MaxSpeed then
			CurrentSpeed = playerInfo.MaxSpeed
		end
	end

	RunnerGameMineEffect.CurrentSpeed = CurrentSpeed

	-- 移动
	CurrentDistance += CurrentSpeed * deltaTime
	if CurrentDistance > Define.Game.MaxDistance then
		CurrentDistance = 0
	end

	local pos = RunnerMiningTrackUpdator:GetPlayerPosByDistance(player, CurrentDistance)
	
	-- ====== 新增：左右自由移动，仅表现 ======
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid and GameInfo.GamePhase == Define.GamePhase.Gaming then
		local moveX = RunnerMiningTrackUpdator:GetPlayerInputX(player)
		if math.abs(moveX) > 0.05 then
			LateralOffset += moveX * TurnSpeed * deltaTime
		end
	end

	-- 限制左右偏移范围
	LateralOffset = math.clamp(LateralOffset, RangeLeft, RangeRight)

	-- 应用偏移（X 为左右方向）
	pos = pos + Vector3.new(LateralOffset, 0, 0)
	
	-- ====== 新增结束 ======
	--humanoid:Move(pos)
	
	--AlignPos.Attachment0 = rootPart.RootRigAttachment
	--AlignPos.Parent = rootPart
	--AlignPos.Position = pos

	rootPart.CFrame = CFrame.new(pos)
end

function RunnerMiningTrackUpdator:GetPlayerInputX(player)
	local humanoid = PlayerManager:GetHumanoid(player)
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	local moveDirection = humanoid.MoveDirection
	local playerCFrame = rootPart.CFrame
	local rightVector = playerCFrame.RightVector
	local xAxisInput = moveDirection:Dot(rightVector)
	xAxisInput = math.clamp(xAxisInput, -1, 1)
	return xAxisInput
end

-------------------------------------------------------------------------------------------------------------------------

-- Track

function RunnerMiningTrackUpdator:GetTrackStartPos(trackIndex)
	local trackPart = TrackPartList[trackIndex]
	return trackPart.Position
end

function RunnerMiningTrackUpdator:OnGetCoinReward()
	local fxPrefab = Util:LoadPrefab("Fx/UI/FxConfetti")
	Util:SpawnScreenFx(fxPrefab, 2)
	SoundManager:PlaySFX(SoundManager.Define.Celebrate)
end

return RunnerMiningTrackUpdator
