 local UserInputService = game:GetService("UserInputService")

local ProximityArea = require(game.ReplicatedStorage.ScriptAlias.ProximityArea)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local BigNumber = require(game.ReplicatedStorage.ScriptAlias.BigNumber)
local NetClinet = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local TrainingMachineMananger = require(game.ReplicatedStorage.ScriptAlias.TrainingMachineMananger)
local SoundMnaager = require(game.ReplicatedStorage.ScriptAlias.SoundManager)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local UTween = require(game.ReplicatedStorage.ScriptAlias.UTween)
local Building = require(game.ReplicatedStorage.ScriptAlias.Building)

local Define = require(game.ReplicatedStorage.Define)

local TrainingMachine = {}

local CurrentTrainingInfo = nil
local ToolData = nil
local PlayerPos = nil

function TrainingMachine:Handle(buildingPart, opts, index)
	local data = ConfigManager:GetData("Training", index)
	local trainingInfo = {
		TrainingMachine = self,
		BuildingPart = buildingPart,
		TriggerPart = opts.TriggerPart,
		Index = index,
		Data = data,
		IsLock = true,
		Fx = Util:LoadPrefab(data.FX),
	}
	
	local building = Building.Proximity(buildingPart, opts, Define.Message.EnterTrainingMachine, function()
		TrainingMachine:Start(trainingInfo)
	end)

	building.RefreshFunc = function()
		NetClinet:Request("Player", "GetRecord", { 
			Key = Define.PlayerRecord.MaxTrainingPower 
		}, function(maxTrainingPower)
			trainingInfo.IsLock = maxTrainingPower < trainingInfo.Data.RequirePower
			TrainingMachine:Refresh(trainingInfo.BuildingPart, trainingInfo)
		end)
	end

	building:Refresh()
	
	-- 破记录时自动刷新
	EventManager:Listen(EventManager.Define.RefreshRecord, function(param)
		building:Refresh()
	end)

	TrainingMachineMananger:Register(trainingInfo)
end

function TrainingMachine:Start(trainingInfo)
	if trainingInfo.IsLock then
		UIManager:ShowMessage(Define.Message.TrainingLock)
		return
	end
	
	CurrentTrainingInfo = trainingInfo
	NetClinet:Request("Training", "Start", { Index = trainingInfo.Index }, function(result)
		if not result then return end
		if not result.Success then return end
		ToolData = result.ToolData
		
		local playerPosPart = Util:GetChildByName(trainingInfo.BuildingPart, "PlayerPos")
		local proximityPrompt = Util:GetChildByType(trainingInfo.TriggerPart, "ProximityPrompt")
		proximityPrompt.Enabled = false
		local toolOffset = Vector3.new(ToolData.TrainingOffsetX, ToolData.TrainingOffsetY, ToolData.TrainingOffsetZ)
		PlayerPos = playerPosPart.Position + toolOffset
		
		NetClinet:Request("Player", "SetPosition", { Position = PlayerPos})
		NetClinet:Request("Player", "SetRotation", { Rotation = playerPosPart.Orientation })
		--NetClinet:Request("Player", "DisablePhysic" )
		TrainingMachine:StartListenCancel()
		
		if CurrentTrainingInfo and CurrentTrainingInfo.BuildingPart then
			local texturePart = Util:GetChildByName(CurrentTrainingInfo.BuildingPart, "Texture")
			if texturePart then
				CurrentTrainingInfo.Animation = UTween:Value(0, 9, 0.25, function(value)
					texturePart.OffsetStudsV = value
				end)
					:SetLoop(UTween.LoopType.Loop, 0)
			end
		end
	end)
end

function TrainingMachine:End()
	local trainingInfo = CurrentTrainingInfo
	if not trainingInfo then return end
	NetClinet:Request("Training", "End", function(result)
		if not result then return end

		--NetClinet:Request("Player", "EnablePhysic" )
		local proximityPrompt = Util:GetChildByType(trainingInfo.TriggerPart, "ProximityPrompt")
		proximityPrompt.Enabled = true

		TrainingMachine:EndListenCancel()
		if CurrentTrainingInfo then
			if CurrentTrainingInfo.Animation ~= nil then
				CurrentTrainingInfo.Animation:Stop()
				CurrentTrainingInfo.Animation = nil
			end

			CurrentTrainingInfo = nil
		end	
	end)	
end

local function randomEdge(min1, max1, min2, max2)
	if math.random(0,1) == 0 then
		return math.random(min1, max1)
	else
		return math.random(min2, max2)
	end
end

function TrainingMachine:OnTraining(player, param)
	-- Message
	--local message = param.Message
	--UIManager:ShowMessage(message)

	-- SFX
	if ToolData then
		local type = ToolData.Type
		if type == "Car" then
			SoundMnaager:PlaySFX(SoundMnaager.Define.TrainingCar)

			--local from = PlayerManager:GetPosition(player)
			--local to = from + Vector3.new(0, 0, 0.5)
			--UTween:PlayerPosition(player, from, to, 0.3)
			--	:SetEase(UTween.EaseType.Dash)
		end

		if type == "Tool" then
			SoundMnaager:PlaySFX(SoundMnaager.Define.TrainingTool)
		end
	end
	
	-- FX
	if CurrentTrainingInfo then
		Util:SpawnFxEmit(CurrentTrainingInfo.Fx, CurrentTrainingInfo.TriggerPart.Position, 20)
	end
	
	-- Animation
	--if CurrentTrainingInfo and CurrentTrainingInfo.BuildingPart then
	--	local partList = CurrentTrainingInfo.BuildingPart.Model.Mine:GetDescendants()
	--	for _, minePart in ipairs(partList) do
	--		local randX = randomEdge(-20, -15, 15, 20)
	--		local randZ = randomEdge(-20, -15, 15, 20)
	--		UTween:ModelRotation(minePart, Vector3.new(0,0,0), Vector3.new(randX, 0, randZ), 0.5)
	--			:SetDelay(0.15)
	--			:SetEase(UTween.EaseType.Shake, 3)
	--	end	
	--end	
end

local CancelConnection = nil

function TrainingMachine:StartListenCancel()
	local player = game.Players.LocalPlayer
	local humanoid = PlayerManager:GetHumanoid(player)
	if not humanoid then return end
	CancelConnection = humanoid.Jumping:Connect(function(isJumping)
		TrainingMachine:OnInputJump(isJumping)
	end)
end

function TrainingMachine:EndListenCancel()
	if not CancelConnection then return end
	CancelConnection:Disconnect()
	CancelConnection = nil
end

function TrainingMachine:OnInputJump(isJumping)
	if isJumping and CurrentTrainingInfo then
		TrainingMachine:End()
	end
end

function TrainingMachine:Refresh(buildingPart, trainingInfo)
	local data = trainingInfo.Data
	local info = {
		RequirePower = data.RequirePower,
		RewardPower = data.RewardPower,
		IsLock = trainingInfo.IsLock
	}
	
	TrainingMachineMananger:Refresh(trainingInfo)

	UIInfo:SetInfo(buildingPart, info)
	local textRequirePower = Util:GetChildByName(buildingPart, "Text_RequirePower")
	textRequirePower.Text = BigNumber:Format(data.RequirePower).." Required"
	local textRewewardPower = Util:GetChildByName(buildingPart, "Text_RewardPower")
	textRewewardPower.Text = "+"..BigNumber:Format(data.RewardPower).." Power"
end

return TrainingMachine
