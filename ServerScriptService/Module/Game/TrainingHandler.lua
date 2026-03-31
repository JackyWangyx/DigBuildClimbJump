local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local BigNumber = require(game.ReplicatedStorage.ScriptAlias.BigNumber)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)

local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)
local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)
local PlayerProperty = require(game.ServerScriptService.ScriptAlias.PlayerProperty)
local PlayerStatus = require(game.ServerScriptService.ScriptAlias.PlayerStatus)


local TrainingHandler = {}

local TrainingDic = {}

function TrainingHandler:Init()
	PlayerManager:HandleCharacterAddRemove(function(player, character)
		
	end, function(player, character)
		TrainingHandler:End(player)
	end)
	
	local connection = UpdatorManager:Heartbeat(function(deltaTime)
		TrainingHandler:Update(deltaTime)
	end)
	
	game:BindToClose(function()
		connection:Disconnect()
	end)
end

function TrainingHandler:Start(player, index)
	if not player then return end
	if TrainingDic[player] then 
		return {
			Success = false,
			ToolData = nil,
		} 
	end	
	
	local equipToolInfo = NetServer:RequireModule("Tool"):GetEquip(player)	
	if not equipToolInfo then
		return {
			Success = false,
			ToolData = nil,
		} 
	end
	
	local toolData = ConfigManager:GetData("Tool", equipToolInfo.ID)	
	local trainingData = ConfigManager:GetData("Training", index)
	local trainingInfo = {
		Player = player,
		Index = index,
		Data = trainingData,
		StartTime = tick(),
		LastTime = tick(),
		ToolData = toolData,
	}
	
	TrainingDic[player] = trainingInfo
	
	if toolData.Type == "Car" then
		PlayerManager:EnableJump(player)
	end
	
	PlayerManager:DisableMove(player)
	PlayerManager:DisablePhysic(player)
	-- 停止跑步播放训练
	PlayerManager:StopAnimation(player, trainingInfo.ToolData.RunAnimation)
	PlayerManager:PlayAnimation(player, trainingInfo.ToolData.TrainingAnimation, true, trainingInfo.Data.AnimationSpeed)
	
	PlayerStatus:SetStatus(player, PlayerStatus.Define.Training)
	EventManager:DispatchToClient(player, EventManager.Define.TrainingStart)
	AnalyticsManager:Event(player, AnalyticsManager.Define.PlayTraining, "TrainingID", trainingData.ID)
	
	return {
		Success = true,
		ToolData = toolData
	}
end

function TrainingHandler:End(player)
	if not TrainingDic[player] then
		return false
	end
	
	local trainingInfo = TrainingDic[player]
	if trainingInfo.ToolData.Type == "Car" then
		PlayerManager:DisableJump(player)
	end
	
	PlayerManager:EnableMove(player)
	PlayerManager:EnablePhysic(player)
	-- 停止训练播放跑步
	PlayerManager:StopAnimation(player, trainingInfo.ToolData.TrainingAnimation)
	PlayerManager:PlayAnimation(player, trainingInfo.ToolData.RunAnimation, true, 1)
	
	TrainingDic[player] = nil
	PlayerStatus:SetStatus(player, PlayerStatus.Define.Idle)
	EventManager:DispatchToClient(player, EventManager.Define.TrainingEnd)
	return true
end

function TrainingHandler:Update(deltaTime)
	local currentTime = tick()
	for _, trainInfo in pairs(TrainingDic) do
		local diffTime = currentTime - trainInfo.LastTime
		if diffTime < trainInfo.Data.Interval then
			continue
		end
			
		trainInfo.LastTime = currentTime
		local player = trainInfo.Player
		if not PlayerPrefs:GetPlayerSaveInfoState(player) then
			continue
		end
		
		local rewardPower = trainInfo.Data.RewardPower
		local getPowerFactor = PlayerProperty:GetGamePropertyValue(player, PlayerProperty.Define.GET_POWER_FACTOR)
		rewardPower = math.round(rewardPower * getPowerFactor)
		NetServer:RequireModule("Training"):AddPower(player, { Value = rewardPower })

		--local message = Util:ToColorText("+"..BigNumber:Format(rewardPower).." Power ", Color3.new(0.235294, 1, 0))
		NetServer:Broadcast(player, "Training", "OnTraining", {
			--Message = message, 
			--Value = rewardPower, 
			--ToolData = trainInfo.ToolData 
		})
	end
end

return TrainingHandler
