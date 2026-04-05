local RunService = game:GetService("RunService")

local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local LogUtil = require(game.ReplicatedStorage.ScriptAlias.LogUtil)

local Define = require(game.ReplicatedStorage.Define)

local GameClient = {}

--local UILoadingPrefab = nil
local UILoading = nil
local LoadingList = {}

local UpdateConnection = nil
local CurrentProgress = 0
local TargetProgress = 0
local Info = nil

local function GetUILoading()
	local player = game.Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	local ui = playerGui:WaitForChild("UILoading")
	return ui
end

function GameClient:Init()
	CurrentProgress = 0
	TargetProgress = 0
	UILoading = GetUILoading()
	UpdateConnection = RunService.Heartbeat:Connect(function(deltaTime)
		GameClient:Update(deltaTime)
	end)
	
	task.wait()
	
	-- System
	GameClient:RegisterLoadProcess("Log Util", LogUtil)
	GameClient:RegisterLoadProcess("Net Client", require(game.ReplicatedStorage.ScriptAlias.NetClient))
	GameClient:RegisterLoadProcess("Game Loader", require(game.ReplicatedStorage.ScriptAlias.GameLoader))
	
	GameClient:RegisterLoadProcess("Resources Manager", require(game.ReplicatedStorage.ScriptAlias.ResourcesManager))
	GameClient:RegisterLoadProcess("Scene Manager", require(game.ReplicatedStorage.ScriptAlias.SceneManager))
	GameClient:RegisterLoadProcess("Scene Area Manager", require(game.ReplicatedStorage.ScriptAlias.SceneAreaManager))
	GameClient:RegisterLoadProcess("Scene Reward Manager", require(game.ReplicatedStorage.ScriptAlias.SceneRewardManager))
	GameClient:RegisterLoadProcess("IAP Client",  require(game.ReplicatedStorage.ScriptAlias.IAPClient))
	GameClient:RegisterLoadProcess("Trade Client", require(game.ReplicatedStorage.ScriptAlias.TradeClient))
	GameClient:RegisterLoadProcess("Friend Manager", require(game.ReplicatedStorage.ScriptAlias.FriendManager))
	GameClient:RegisterLoadProcess("Player Manager", require(game.ReplicatedStorage.ScriptAlias.PlayerManager))
	GameClient:RegisterLoadProcess("UI Manager", require(game.ReplicatedStorage.ScriptAlias.UIManager))
	
	GameClient:RegisterLoadProcess("Building Manager", require(game.ReplicatedStorage.ScriptAlias.BuildingManager))
	
	-- GamePlay
	GameClient:RegisterLoadProcess("Game Manager", require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameManager))
	--GameClient:RegisterLoadProcess("Auto Play", require(game.ReplicatedStorage.ScriptAlias.RunnerAutoPlay))
	--GameClient:RegisterLoadProcess("Mining Track Updator", require(game.ReplicatedStorage.ScriptAlias.RunnerMiningTrackUpdator))
	--GameClient:RegisterLoadProcess("Road Updator", require(game.ReplicatedStorage.ScriptAlias.RunnerRoadUpdator))
	GameClient:RegisterLoadProcess("Pet Client Handler", require(game.ReplicatedStorage.ScriptAlias.PetClientHandler))
	--GameClient:RegisterLoadProcess("Animal Updator", require(game.ReplicatedStorage.ScriptAlias.AnimalUpdator))
	GameClient:RegisterLoadProcess("Tool Updator", require(game.ReplicatedStorage.ScriptAlias.ToolUpdator))
	GameClient:RegisterLoadProcess("Equipment Updator", require(game.ReplicatedStorage.ScriptAlias.EquipmentUpdator))
	
	GameClient:RegisterLoadProcess("Sound Manager", require(game.ReplicatedStorage.ScriptAlias.SoundManager))
	GameClient:RegisterLoadProcess("Debug Client", require(game.ReplicatedStorage.ScriptAlias.DebugClient))	
	GameClient:RegisterLoadProcess("Camera Manager", require(game.ReplicatedStorage.ScriptAlias.CameraManager))	
	
	GameClient:RegisterLoadProcess("Guide Manager", require(game.ReplicatedStorage.ScriptAlias.GuideManager))
	
	task.spawn(function()
		local success = GameClient:StartLoading()
		if success then

			--if Define.Test.TestBuild then
			--	local build = require(game.ReplicatedStorage.ScriptAlias.BuildManager)
			--	build:Init()
			--	build:BuildStart()
			--end
			
		else

		end
	end)
end

function GameClient:StartLoading()
	
	local count = #LoadingList
	Info = {
		Index = 0,
		Count = count,
		Progress = 0,
		ProgressText = "0%"
	}

	GameClient:RefreshProgress(Info)
	
	task.wait()
	for index, loadData in ipairs(LoadingList) do
		task.wait()
		local name = loadData.Name
		local module = loadData.Module
		local startTime = tick()
		
		Info.Name = name
		Info.Index = index
		
		local progress = Util:RoundFloat((index - 1) * 1.0 / count, 2)
		
		Info = {
			Name = name,
			Index = index,
			Count = count,
			Progress = progress,
			Time = 0,
			ProgressText = math.round(progress * 100).."%"
		}
		
		GameClient:RefreshProgress(Info)
		
		local loadComplete = false
		local loadSuccess = GameClient:LoadProcess(module, function(complete)
			loadComplete = complete
		end)	
		if not loadSuccess then
			LogUtil:Warn("[Client] Load Failed!", name, module)
			return false
		end
		
		while not loadComplete do
			task.wait()
		end
		
		local endTime = tick()
		local spendTime = Util:RoundFloat((endTime - startTime) * 1000, 3)	
		progress = Util:RoundFloat(index * 1.0 / count, 2)
		Info.Time = spendTime
		Info.Progress = progress
		GameClient:RefreshProgress(Info)
		
		while spendTime < 0.15 do
			spendTime += 1.0 / 60
			task.wait()
		end
		
		TargetProgress = progress
		
		--LogUtil:Log(name, progress, spendTime.." ms")
		task.wait()
	end
	
	LogUtil:Log("[Client] Load Success!")
	
	task.wait()
	
	UpdateConnection:Disconnect()
	
	UILoading.Enabled = false
	UILoading:Destroy()
	UILoading = nil
	
	return true
end

function GameClient:RegisterLoadProcess(name, module)
	table.insert(LoadingList, {
		Name = name,
		Module = module,
	})
end

function GameClient:LoadProcess(loadModule, onDone)
	local complete = false
	local success, result = pcall(function()
		task.spawn(function()
			local initFunc = loadModule["Init"]
			if initFunc then
				initFunc(loadModule)
			end
			
			complete = true
			if onDone then
				onDone(true)
			end	
		end)
	end)

	if success then
		return true
	else
		warn("[Client] Init Fail : ", debug.traceback(result, 2))
		return false
	end
end

function GameClient:Update(deltaTime)
	if not Info then return end
	local speed = 6  
	CurrentProgress = CurrentProgress + (TargetProgress - CurrentProgress) * math.clamp(deltaTime * speed, 0, 1)
	Info.Progress = CurrentProgress
	Info.ProgressText = math.round(CurrentProgress * 100) .. "%"
	GameClient:RefreshProgress(Info)
end

function GameClient:RefreshProgress(info)
	UIInfo:SetInfo(UILoading, info)
end

return GameClient
