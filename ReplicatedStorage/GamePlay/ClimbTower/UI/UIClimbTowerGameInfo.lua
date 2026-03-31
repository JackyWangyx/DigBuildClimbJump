local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local AttributeUtil = require(game.ReplicatedStorage.ScriptAlias.AttributeUtil)

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

function UIClimbTowerGameInfo:Init(root)
	UIClimbTowerGameInfo.UIRoot = root
	UIInfo:HandleAllButton(root, UIClimbTowerGameInfo)

	UIClimbTowerGameInfo.GameFrame = Util:GetChildByName(root, "GameFrame")
	UIClimbTowerGameInfo.PlayerGameFrame = Util:GetChildByName(root, "PlayerGameFrame")
	UIClimbTowerGameInfo.BottonRankTrans = Util:GetChildByName(UIClimbTowerGameInfo.GameFrame, "BottonRankTrans", true)
	UIClimbTowerGameInfo.RankBar = Util:GetChildByName(UIClimbTowerGameInfo.GameFrame, "RankBar", true)
	
	UIClimbTowerGameInfo.UIPowerTarget = Util:GetChildByName(root, "UIPowerTarget", true)
	
	UIClimbTowerGameInfo.PlayerGameFrame.Visible = false
	
	UIClimbTowerGameInfo.DigFrame = Util:GetChildByName(root, "DigFrame", true)
	UIClimbTowerGameInfo.IdleFrame = Util:GetChildByName(root, "IdleFrame", true)
	
	UIClimbTowerGameInfo.DigFrame.Visible = false
	UIClimbTowerGameInfo.IdleFrame.Visible = true
	
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
end

function UIClimbTowerGameInfo:Refresh()	
	UIClimbTowerGameInfo:RefreshPlayerInfo()
	
	local updateGameInfo = ClimbTowerGameManager.UpdateGameInfo
	UIClimbTowerGameInfo:RefreshBottonRank(updateGameInfo)
	
	UIClimbTowerGameInfo:RefreshDigInfo()
end

function UIClimbTowerGameInfo:RefreshDigInfo()
	if not ClimbTowerGameManager.IsDigPhase then 
		local info = {
			IsDigging = false
		}

		UIInfo:SetInfo(UIClimbTowerGameInfo.DigFrame, info)
		return 
	end
	
	local progress = ClimbTowerGameManager.DigIntervalTimer / ClimbTowerGameManager.EquipmentData.DigInterval
	local info = {
		IsDigging = ClimbTowerGameManager.IsDigging,
		DigProgress = progress,
		DigProgressValue = math.round(progress * 100) .. "%"
	}
	
	UIInfo:SetInfo(UIClimbTowerGameInfo.DigFrame, info)
end

function UIClimbTowerGameInfo:RefreshToolInfo()
	local toolData = ClimbTowerGameManager.ToolData
	if not toolData then return end
	local info = {
		PowerCapacity = toolData.PowerCapacity,
	}
	
	UIInfo:SetInfo(UIClimbTowerGameInfo.UIPowerTarget, info)
end

function UIClimbTowerGameInfo:RefreshPlayerInfo()
	if not UIClimbTowerGameInfo.IsInGame then return end
	
	local gameInitParam = ClimbTowerGameLoop.GameInitParam
	local updateInfo = ClimbTowerGameLoop.UpdateInfo
	if not updateInfo or not gameInitParam then return end

	local info = {
		GetCoin = math.round(updateInfo.ArriveDistance * gameInitParam.RewardCoinPerMeter),
		MoveDistance = math.round(updateInfo.ArriveDistance),
	}

	UIInfo:SetInfo(UIClimbTowerGameInfo.PlayerGameFrame, info)
end

------------------------------------------------------------------------------
-- Rank

function UIClimbTowerGameInfo:RefreshBottonRank(updateGameInfo)
	local rankList = UIClimbTowerGameInfo:GetRankList(updateGameInfo)
	local itemList = UIList:LoadWithInfo(UIClimbTowerGameInfo.BottonRankTrans, "UIBottonRankItem", rankList)
	UIList:HadnlePlayerHeadIconAsync(itemList)

	for _, item in ipairs(itemList) do
		local progress = AttributeUtil:GetInfoValue(item, "Progress")
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
	if pointer.Parent then
		local parentAbsPos = pointer.Parent.AbsolutePosition
		local relativeX = targetAbsX - parentAbsPos.X
		local relativeY = targetAbsY - parentAbsPos.Y
		pointer.Position = UDim2.new(0, relativeX, 0, relativeY)
	end
end

function UIClimbTowerGameInfo:GetRankList(updateGameInfo)
	local result = {}
	local localPlayer = game.Players.LocalPlayer
	local selfInfo = nil

	if not updateGameInfo then return end
	for _, playerInfo in ipairs(updateGameInfo) do
		local playerID = playerInfo.PlayerID
		local player = PlayerManager:GetPlayerById(playerID)

		if player then
			local rankInfo = {
				UserID = playerID,
				Distance = playerInfo.Distance,
				Progress = 1 - playerInfo.Progress,
				IsSelf = playerID == localPlayer.UserId,
			}

			if rankInfo.IsSelf then
				selfInfo = rankInfo
			else
				table.insert(result, rankInfo)
			end
		end
	end

	if selfInfo then
		table.insert(result, selfInfo)
	end

	return result
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
