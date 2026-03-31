local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)

local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local AttributeUtil = require(game.ReplicatedStorage.ScriptAlias.AttributeUtil)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local TimeUtil = require(game.ReplicatedStorage.ScriptAlias.TimeUtil)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local LerpUtil = require(game.ReplicatedStorage.ScriptAlias.LerpUtil)

local Define = require(game.ReplicatedStorage.Define)

local UIRunnerGameInfo = {}

UIRunnerGameInfo.GameFrame = nil
UIRunnerGameInfo.TopRankTrans = nil
UIRunnerGameInfo.BottonRankTrans = nil
UIRunnerGameInfo.RankBar = {}

UIRunnerGameInfo.TextGameTimer = nil
UIRunnerGameInfo.ImageSpeedArrow = nil

function UIRunnerGameInfo:Init(root)
	local childList = root:GetDescendants()
	
	UIRunnerGameInfo.GameFrame = Util:GetChildByName(root, "GameFrame", true, childList)
	UIRunnerGameInfo.PlayerGameFrame = Util:GetChildByName(root, "PlayerGameFrame", true, childList)
	
	EventManager:Listen(EventManager.Define.PetLootStart, function()
		UIRunnerGameInfo.GameFrame.Visible = false
	end)
	
	EventManager:Listen(EventManager.Define.PetLootEnd, function()
		UIRunnerGameInfo.GameFrame.Visible = true
	end)
	
	UIRunnerGameInfo.TopRankTrans = Util:GetChildByName(UIRunnerGameInfo.GameFrame, "TopRankTrans", true, childList)
	UIRunnerGameInfo.BottonRankTrans = Util:GetChildByName(UIRunnerGameInfo.GameFrame, "BottonRankTrans", true, childList)
	UIRunnerGameInfo.RankBar[1] = Util:GetChildByName(UIRunnerGameInfo.GameFrame, "RankBar01", true, childList)
	UIRunnerGameInfo.RankBar[2] = Util:GetChildByName(UIRunnerGameInfo.GameFrame, "RankBar02", true, childList)
	UIRunnerGameInfo.RankBar[3] = Util:GetChildByName(UIRunnerGameInfo.GameFrame, "RankBar03", true, childList)

	UIRunnerGameInfo.TextGameTimer = Util:GetChildByName(root, "Text_GameTimer", true, childList)
	UIRunnerGameInfo.ImageSpeedArrow = Util:GetChildByName(root, "Image_SpeedArrow", true, childList)
	
	EventManager:Listen(EventManager.Define.RefreshGameInfo, function(gameInfo, playerList)
		UIRunnerGameInfo:RefreshGameInfo(gameInfo, playerList)
	end)
	
	EventManager:Listen(EventManager.Define.GameStartNewLoop, function()
		UIRunnerGameInfo.ReceiveData = nil
	end)
	
	UpdatorManager:Heartbeat(function(deltaTime)
		UIRunnerGameInfo:Update(deltaTime)
	end)
end

function UIRunnerGameInfo:RefreshGameInfo(param)
	if UIRunnerGameInfo.ReceiveData == nil then
		UIRunnerGameInfo.ReceiveData = param
		UIRunnerGameInfo:SetCurrentInfo()
	else
		UIRunnerGameInfo.ReceiveData = param
	end
	
	UIRunnerGameInfo:SetTargetInfo(param)
	
	local gameInfo = param.GameInfo
	local playerList = param.PlayerList
	
	local player = game.Players.LocalPlayer
	local currentPage = UIManager:GetCurrentPage()
	local isInLoot = false
	if currentPage and currentPage.Name == "UIPetLootResult" then
		isInLoot = true
	end
	local visibleGameInfo = (gameInfo.GamePhase == Define.GamePhase.Gaming or gameInfo.GamePhase == Define.GamePhase.Ready) and not isInLoot
	local playerInfo = Util:TableFind(playerList, function(info) return info.ID == player.UserId end)
	local visiblePlayerInfo = playerInfo ~= nil

	UIRunnerGameInfo.GameFrame.Visible = visibleGameInfo
	UIRunnerGameInfo.PlayerGameFrame.Visible = visiblePlayerInfo
	if visiblePlayerInfo then
		local uiInfo = {
			Distance = playerInfo.Distance,
			Power_Current = playerInfo.CurrentSpeed,
			Power_100 = playerInfo.Power,
			Power_75 = math.round(playerInfo.Power * 0.75),
			Power_50 = math.round(playerInfo.Power * 0.5),
			Power_25 = math.round(playerInfo.Power * 0.25),
		}

		UIInfo:SetInfo(UIRunnerGameInfo.PlayerGameFrame, uiInfo)

		-- 速度指针
		local speedFactor = playerInfo.CurrentSpeed / playerInfo.MaxSpeed
		UIRunnerGameInfo.ImageSpeedArrow.Rotation = math.lerp(-90, 90, speedFactor)
	end
	
	UIRunnerGameInfo:RefreshTopRank(gameInfo, playerList)
	UIRunnerGameInfo:RefreshBottonRank(gameInfo, playerList)
end	

function UIRunnerGameInfo:RefreshTopRank(gameInfo, playerList)
	local rankList = UIRunnerGameInfo:GetRankList(gameInfo, playerList, 3)
	local itemList = UIList:LoadWithInfo(UIRunnerGameInfo.TopRankTrans, "UITopRankItem", rankList)
	
	for index, item in pairs(itemList) do
		local playerID = AttributeUtil:GetInfoValue(item, "UserID")
		local player = PlayerManager:GetPlayerById(playerID)
		PlayerManager:GetHeadIconAsync(player, function(icon)
			if not item then return end
			UIInfo:SetValue(item, "HeadIcon", icon)
		end)
	end
end

function UIRunnerGameInfo:RefreshBottonRank(gameInfo, playerList)
	local rankList = UIRunnerGameInfo:GetRankList(gameInfo, playerList, Define.Game.TrackCount)
	local itemList = UIList:LoadWithInfo(UIRunnerGameInfo.BottonRankTrans, "UIBottonRankItem", rankList)
	UIList:HadnlePlayerHeadIconAsync(itemList)
	
	for _, item in ipairs(itemList) do
		local distance = AttributeUtil:GetInfoValue(item, "Distance")
		local rankInfo = UIRunnerGameInfo:GetRankBarProgress(distance)
		local bar = UIRunnerGameInfo.RankBar[rankInfo.Index]
		local progress = rankInfo.Progress
		UIRunnerGameInfo:UpdateRankPointer(bar, item, progress)
	end
end

function UIRunnerGameInfo:GetRankBarProgress(distance)
	local index = 1
	local progress = 0
	local dis = distance
	while true do
		local rankBarData = Define.Game.RankBar[index]
		if dis >= rankBarData.Length then
			dis -= rankBarData.Length
			index += 1
			if index > 3 then
				index = 1
			end
		else
			progress = dis / rankBarData.Length
			break
		end
	end
	
	if index > 3 then index = 1 end
	if progress > 1 then progress = 1 end
	return {
		Index = index,
		Distance = distance,
		Progress = progress
	}
end

function UIRunnerGameInfo:UpdateRankPointer(progressBar, pointer, percent)
	if not progressBar then return end
	percent = math.clamp(percent, 0, 1)
	local barAbsPos = progressBar.AbsolutePosition
	local barAbsSize = progressBar.AbsoluteSize
	local pointerSize = pointer.AbsoluteSize
	local targetAbsX = barAbsPos.X + (barAbsSize.X * percent) - (pointerSize.X / 2)
	local targetAbsY = barAbsPos.Y + (barAbsSize.Y / 2) - (pointerSize.Y / 2) 
	if pointer.Parent then
		local parentAbsPos = pointer.Parent.AbsolutePosition
		local relativeX = targetAbsX - parentAbsPos.X
		local relativeY = targetAbsY - parentAbsPos.Y
		pointer.Position = UDim2.new(0, relativeX, 0, relativeY)
	end
end

function UIRunnerGameInfo:GetRankList(gameInfo, playerList, count)
	local result = {}
	if gameInfo.GamePhase ~= Define.GamePhase.Gaming then
		return result
	end

	local rankList = {}
	for _, playerInfo in pairs(playerList) do
		local playerID = playerInfo.ID 
		local player = PlayerManager:GetPlayerById(playerInfo.ID)
		local rankInfo = {
			UserID = playerInfo.ID,
			RewardCoin = playerInfo.RewardCoin,
			RankValue = 1,
			Rank = "",
			Distance = playerInfo.Distance,
		}

		table.insert(rankList, rankInfo)
	end

	rankList = Util:ListSort(rankList, {
		function(info) return -info.RewardCoin end
	})

	for index, info in pairs(rankList) do
		info.Rank = Define.Game.RankStr[index]
	end

	if count then
		result = Util:ListSelectStart(rankList, count)
	end

	return result
end

-- Lerp

UIRunnerGameInfo.ReceiveData = nil
UIRunnerGameInfo.CurrentInfo = nil
UIRunnerGameInfo.TargetInfo = nil

function UIRunnerGameInfo:SetCurrentInfo()
	if not UIRunnerGameInfo.ReceiveData then return end
	local gameInfo = UIRunnerGameInfo.ReceiveData.GameInfo
	local playerList = UIRunnerGameInfo.ReceiveData.PlayerList
	if not UIRunnerGameInfo.CurrentInfo then
		UIRunnerGameInfo.CurrentInfo = {}
	end
	
	UIRunnerGameInfo.CurrentInfo.GameTimer = gameInfo.GameTimer
end

function UIRunnerGameInfo:SetTargetInfo(param)
	local gameInfo = param.GameInfo
	local playerList = param.PlayerList
	if not UIRunnerGameInfo.TargetInfo then
		UIRunnerGameInfo.TargetInfo = {}
	end
	
	UIRunnerGameInfo.TargetInfo.GameTimer = gameInfo.GameTimer
end

function UIRunnerGameInfo:Update(deltaTime)
	if not UIRunnerGameInfo.TargetInfo then return end
	UIRunnerGameInfo.CurrentInfo.GameTimer = math.lerp(UIRunnerGameInfo.CurrentInfo.GameTimer, UIRunnerGameInfo.TargetInfo.GameTimer, 10 * deltaTime)
	local str = TimeUtil:FormatMsToMMSSMS(UIRunnerGameInfo.CurrentInfo.GameTimer)
	UIRunnerGameInfo.TextGameTimer.Text = str
end

return UIRunnerGameInfo
