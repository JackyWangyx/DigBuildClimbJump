local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local ObjectInfo = require(game.ReplicatedStorage.ScriptAlias.ObjectInfo)
local SceneAreaManager = require(game.ReplicatedStorage.ScriptAlias.SceneAreaManager)
local TimeUtil = require(game.ReplicatedStorage.ScriptAlias.TimeUtil)
local UIIndexManager = require(game.ReplicatedStorage.ScriptAlias.UIIndexManager)

local UISceneReward = require(game.ReplicatedStorage.ScriptAlias.UISceneReward)
local ClimbTowerGameManager = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameManager)
local ClimbTowerGameLoop = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameLoop)
local ClimbTowerDefine = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerDefine)

local Define = require(game.ReplicatedStorage.Define)

local UIClimbTowerGameInfo = {}

UIClimbTowerGameInfo.UIRoot = nil

UIClimbTowerGameInfo.GameFrame = nil
UIClimbTowerGameInfo.PlayerGameFrame = nil
UIClimbTowerGameInfo.BottonRankTrans = nil
UIClimbTowerGameInfo.RankBar = nil
UIClimbTowerGameInfo.IsInGame = false

UIClimbTowerGameInfo.UIPowerTarget = nil

UIClimbTowerGameInfo.DigFrame = nil
UIClimbTowerGameInfo.IdleFrame = nil

local RankInfoList = {}
local RankItemList = nil
local IsPlayerChanged = true

function UIClimbTowerGameInfo:Init(root)
	UIClimbTowerGameInfo.UIRoot = root
	UIInfo:HandleAllButton(root, UIClimbTowerGameInfo)
	
	UIClimbTowerGameInfo.GameFrame = UIIndexManager:GetChildByName(root, "GameFrame")
	UIClimbTowerGameInfo.PlayerGameFrame = UIIndexManager:GetChildByName(root, "PlayerGameFrame")
	UIClimbTowerGameInfo.BottonRankTrans = UIIndexManager:GetChildByName(UIClimbTowerGameInfo.GameFrame, "BottonRankTrans")
	UIClimbTowerGameInfo.RankBar = UIIndexManager:GetChildByName(UIClimbTowerGameInfo.GameFrame, "RankBar")
	
	UISceneReward:Init(UIClimbTowerGameInfo.GameFrame)
	
	UIClimbTowerGameInfo.UIPowerTarget = UIIndexManager:GetChildByName(root, "UIPowerTarget")
	
	UIClimbTowerGameInfo.PlayerGameFrame.Visible = false
	
	UIClimbTowerGameInfo.DigFrame = UIIndexManager:GetChildByName(root, "DigFrame")
	UIClimbTowerGameInfo.IdleFrame = UIIndexManager:GetChildByName(root, "IdleFrame")
	
	UIClimbTowerGameInfo.DigFrame.Visible = false
	UIClimbTowerGameInfo.IdleFrame.Visible = true
	
	PlayerManager:HandlePlayerAddRemove(function(player)
		IsPlayerChanged = true
	end, function(player)
		IsPlayerChanged = true
	end)
	
	EventManager:Listen(ClimbTowerDefine.Event.EnterDig, function(param)
		UIClimbTowerGameInfo.DigFrame.Visible = true
		UIClimbTowerGameInfo.IdleFrame.Visible = false
	end)
	
	EventManager:Listen(ClimbTowerDefine.Event.ExitDig, function(param)
		UIClimbTowerGameInfo.DigFrame.Visible = false
		UIClimbTowerGameInfo.IdleFrame.Visible = true
	end)

	EventManager:Listen(ClimbTowerDefine.Event.Enter, function(param)
		UIClimbTowerGameInfo.PlayerGameFrame.Visible = true
		UIClimbTowerGameInfo.IsInGame = true
		UIClimbTowerGameInfo.IdleFrame.Visible = false
	end)

	EventManager:Listen(ClimbTowerDefine.Event.ArriveEnd, function()
		
	end)

	EventManager:Listen(ClimbTowerDefine.Event.Slide, function()
	
	end)

	EventManager:Listen(ClimbTowerDefine.Event.Exit, function()
		UIClimbTowerGameInfo.PlayerGameFrame.Visible = false
		UIClimbTowerGameInfo.IsInGame = false
		UIClimbTowerGameInfo.IdleFrame.Visible = true
	end)

	UIClimbTowerGameInfo:Refresh()
	
	UpdatorManager:RenderStepped(function(deltaTime)
		UIClimbTowerGameInfo:Refresh()
	end)
	
	--UpdatorManager:RenderStepped(function(deltaTime)
	
	--end, 0.1)
	
	EventManager:Listen(ClimbTowerDefine.Event.BuildTower, function()
		UIClimbTowerGameInfo:RefreshBuildInfo()
	end)
end

function UIClimbTowerGameInfo:ShowClimbButtons()
	UIClimbTowerGameInfo.PlayerGameFrame.Botton.Visible = true
end

function UIClimbTowerGameInfo:HideClimbButtons()
	UIClimbTowerGameInfo.PlayerGameFrame.Botton.Visible = false
end

function UIClimbTowerGameInfo:Refresh()	
	UIClimbTowerGameInfo:RefreshPlayerInfo()
	
	UIClimbTowerGameInfo:RefreshDigInfo()
	UIClimbTowerGameInfo:RefreshBuildInfo()
	
	local updateGameInfo = ClimbTowerGameManager.UpdateGameInfo
	UIClimbTowerGameInfo:RefreshBottonRank(updateGameInfo)
end

function UIClimbTowerGameInfo:RefreshDigInfo()
	local refreshTime = ClimbTowerDefine.Game.DigAreaResetTime - ClimbTowerGameManager.DigAreaResetTimer
	local refreshText = TimeUtil:FormatSeconds(refreshTime)
	
	if not ClimbTowerGameManager.IsDigPhase then 
		local info = {
			IsDigging = false,
			CountDown = refreshText,
		}

		UIInfo:SetInfo(UIClimbTowerGameInfo.DigFrame, info)
		return 
	end
	
	if ClimbTowerGameManager.EquipmentData then
		local progress = ClimbTowerGameManager.DigIntervalTimer / ClimbTowerGameManager.EquipmentData.DigInterval
		local info = {
			IsDigging = ClimbTowerGameManager.IsDigging,
			DigProgress = progress,
			DigProgressValue = math.round(progress * 100) .. "%",
			CountDown = refreshText,
		}

		UIInfo:SetInfo(UIClimbTowerGameInfo.DigFrame, info)
	end	
end

function UIClimbTowerGameInfo:RefreshToolInfo()
	local toolData = ClimbTowerGameManager.ToolData
	if not toolData then return end
	local info = {
		PowerCapacity = toolData.PowerCapacity,
	}
	
	UIInfo:SetInfo(UIClimbTowerGameInfo.UIPowerTarget, info)
end

function UIClimbTowerGameInfo:RefreshBuildInfo()
	local areaInfo = SceneAreaManager.AreaInfoList[SceneAreaManager.CurrentAreaIndex]
	local buildingProgress = 0
	
	if areaInfo then
		local tower = areaInfo.Area.Game:FindFirstChild("Tower")
		if tower then
			local top = tower:FindFirstChild("Top")
			local root = tower:FindFirstChild("Root")
			if top and root then
				local towerLength = top.Position.Y
				local towerMaxLength = top.Position.Y - root.Position.Y
				buildingProgress = towerLength / towerMaxLength
			end
		end
	end
	
	local info = {
		BuildingProgress = buildingProgress
	}
	
	UIInfo:SetInfo(UIClimbTowerGameInfo.BottonRankTrans, info)
end

function UIClimbTowerGameInfo:RefreshPlayerInfo()
	if not UIClimbTowerGameInfo.IsInGame then return end
	
	local gameInitParam = ClimbTowerGameLoop.GameInitParam
	local updateInfo = ClimbTowerGameLoop.UpdateInfo
	if not updateInfo or not gameInitParam then return end

	local info = {
		GetCoin = math.round(updateInfo.ArriveDistance * gameInitParam.RewardCoinPerMeter * gameInitParam.GetCoinFactor),
		MoveDistance = math.round(updateInfo.ArriveDistance),
	}

	UIInfo:SetInfo(UIClimbTowerGameInfo.PlayerGameFrame, info)
end


------------------------------------------------------------------------------
-- Botton Rank

function UIClimbTowerGameInfo:RefreshBottonRank(updateGameInfo)
	local rankList = nil
	if IsPlayerChanged then
		rankList = UIClimbTowerGameInfo:CreateRankList(updateGameInfo)
		RankItemList = UIList:LoadWithInfo(UIClimbTowerGameInfo.BottonRankTrans, "UIBottonRankItem", rankList)
		UIList:HadnlePlayerHeadIconAsync(RankItemList)
		
		IsPlayerChanged = false
	else
		UIClimbTowerGameInfo:UpdateRankList(updateGameInfo)
		if #RankInfoList == #RankItemList then
			for index = 1, #RankItemList  do
				local info = RankInfoList[index]
				local item = RankItemList[index]
				ObjectInfo:SetInfoValue(item, "Progress", info.Progress)
				UIInfo:SetInfo(item, info)
			end
		end
	end

	for index = 1, #RankItemList do
		local item = RankItemList[index]
		local progress = ObjectInfo:GetInfoValue(item, "Progress")
		local bar = UIClimbTowerGameInfo.RankBar
		UIClimbTowerGameInfo:UpdateRankPointer(bar, item, progress)
	end
end

function UIClimbTowerGameInfo:UpdateRankPointer(progressBar, pointer, percent)
	if not progressBar then return end
	percent = math.clamp(percent, 0, 1)
	local barAbsPos = progressBar.AbsolutePosition
	local barAbsSize = progressBar.AbsoluteSize
	local pointerSize = pointer.AbsoluteSize
	local targetAbsY = barAbsPos.Y + (barAbsSize.Y * percent) - (pointerSize.Y / 2)
	local targetAbsX = barAbsPos.X + (barAbsSize.X / 2) - (pointerSize.X / 2) 
	local parent = pointer.Parent
	if parent then
		local parentAbsPos = parent.AbsolutePosition
		local relativeX = targetAbsX - parentAbsPos.X
		local relativeY = targetAbsY - parentAbsPos.Y
		pointer.Position = UDim2.new(0, relativeX, 0, relativeY)
	end
end

function UIClimbTowerGameInfo:UpdateRankList(updateGameInfo)
	if #RankInfoList == #updateGameInfo then
		for index = 1, #RankInfoList do
			local rankInfo = RankInfoList[index]
			local playerInfo = updateGameInfo[index]
			rankInfo.Distance = playerInfo.Distance
			rankInfo.Progress = 1 - playerInfo.Progress
		end
	else
		IsPlayerChanged = true
	end
	
	return RankInfoList
end

function UIClimbTowerGameInfo:CreateRankList(updateGameInfo)
	table.clear(RankInfoList)
	local localPlayer = game.Players.LocalPlayer
	if not updateGameInfo then return end
	for _, playerInfo in ipairs(updateGameInfo) do
		local playerID = playerInfo.PlayerID
		local player = PlayerManager:GetPlayerById(playerID)
		if player then
			local rankInfo = {
				UserID = playerInfo.PlayerID,
				Distance = playerInfo.Distance,
				Progress = 1 - playerInfo.Progress,
				IsSelf = playerID == localPlayer.UserId,
			}

			RankInfoList[#RankInfoList + 1] = rankInfo
		end
	end
	
	return RankInfoList
end

------------------------------------------------------------------------------
-- Button

function UIClimbTowerGameInfo:Button_Glide()
	ClimbTowerGameManager:Slide()
end

function UIClimbTowerGameInfo:Button_DoubleSpeed()
	--ClimbTowerGameManager:Exit()
end

function UIClimbTowerGameInfo:Button_ExitGame()
	ClimbTowerGameManager:Exit()
end

function UIClimbTowerGameInfo:Button_GoToDig()
	ClimbTowerGameManager:ResetToDigArea()
end

function UIClimbTowerGameInfo:Button_GoToTower()
	ClimbTowerGameManager:ResetToTower()
end

return UIClimbTowerGameInfo
