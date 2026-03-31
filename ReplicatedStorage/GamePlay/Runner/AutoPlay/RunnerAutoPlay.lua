local RunService = game:GetService("RunService")
local Define = require(game.ReplicatedStorage.Define)

local TrainingMachineMananger = require(game.ReplicatedStorage.ScriptAlias.TrainingMachineMananger)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)

local RunnerAutoPlay = {}

local CurrentPlayerStatus = nil

local Info = {
	IsAutoGame = false,
	IsAutoTraining = false,
	IsAutoClick = false,
}

function RunnerAutoPlay:Init()
	Info.IsAutoGame = false
	Info.IsAutoTraining = false
	Info.IsAutoClick = false
	
	CurrentPlayerStatus = Define.PlayerStatus.Idle
	NetClient:Request("Player", "GetStatus", function(status)	
		CurrentPlayerStatus = status	
	end)
	
	EventManager:Listen(EventManager.Define.RefreshPlayerStatus, function(status)
		CurrentPlayerStatus = status
	end)
	
	EventManager:Listen(EventManager.Define.TrainingEnd, function()
		RunnerAutoPlay:EndAutoTraining()
	end)
	
	task.spawn(function() 
		RunnerAutoPlay:AutoPlayCo()
	end)
end

function RunnerAutoPlay:AutoPlayCo()
	task.wait()
	local player = game.Players.LocalPlayer
	while true do
		if Info.IsAutoGame then
			if CurrentPlayerStatus == Define.PlayerStatus.Idle then
				NetClient:Request("Game", "Enter", function(result)	
				end)
				task.wait(1)
			end
		elseif Info.IsAutoTraining then
			if CurrentPlayerStatus == Define.PlayerStatus.Idle then
				local trainingMachineInfo = TrainingMachineMananger:GetBest()
				if trainingMachineInfo then
					trainingMachineInfo.TrainingMachine:Start(trainingMachineInfo)
					task.wait(1)
				end	
			end
		end
			
		task.wait(0.1)
	end
end

function RunnerAutoPlay:GetInfo()
	return Info
end

-- Game

function RunnerAutoPlay:StartAutoGame()
	if Info.IsAutoGame then return end
	Info.IsAutoGame = true
	EventManager:Dispatch(EventManager.Define.RefreshAutoPlay, Info)
end

function RunnerAutoPlay:EndAutoGame()
	if not Info.IsAutoGame then return end
	Info.IsAutoGame = false
	EventManager:Dispatch(EventManager.Define.RefreshAutoPlay, Info)
end

-- Training

function RunnerAutoPlay:StartAutoTraining()
	if Info.IsAutoTraining then	return end
	Info.IsAutoTraining = true
	EventManager:Dispatch(EventManager.Define.RefreshAutoPlay, Info)
end

function RunnerAutoPlay:EndAutoTraining()
	if not Info.IsAutoTraining then	return end
	Info.IsAutoTraining = false
	EventManager:Dispatch(EventManager.Define.RefreshAutoPlay, Info)
end

-- Click

function RunnerAutoPlay:StartAutoClick()
	if Info.IsAutoClick then	return end
	Info.IsAutoClick = true
	EventManager:Dispatch(EventManager.Define.RefreshAutoPlay, Info)
end

function RunnerAutoPlay:EndAutoClick()
	if not Info.IsAutoClick then	return end
	Info.IsAutoClick = false
	EventManager:Dispatch(EventManager.Define.RefreshAutoPlay, Info)
end

return RunnerAutoPlay
