local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)

local PlayerProperty = require(game.ServerScriptService.ScriptAlias.PlayerProperty)
local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)
local IAPServer = require(game.ServerScriptService.ScriptAlias.IAPServer)
local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)

local RewardUtil = require(game.ServerScriptService.ScriptAlias.RewardUtil)
local ThemeRequest = require(game.ServerScriptService.ScriptAlias.Theme)
local AccountRequest = require(game.ServerScriptService.ScriptAlias.Account)
local ToolRequest = require(game.ServerScriptService.ScriptAlias.Tool)
local EquipmentRequest = require(game.ServerScriptService.ScriptAlias.Equipment)

local ClimbTowerDefine = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerDefine)

local Define = require(game.ReplicatedStorage.Define)

local ClimbTower = {}

function LoadInfo(player)
	local saveInfo = PlayerPrefs:GetModule(player, "ClimbTower")
	if saveInfo.ThemeList == nil then
		saveInfo.ThemeList = {
			["World01"] = {
				UpgradeCount = 0,
				TowerHeight = ClimbTowerDefine.Game.TowerHeightDefault,
			}
		}
	end
	
	return saveInfo
end

-----------------------------------------------------------------------------------------------
-- Info

function ClimbTower:GetInfo(player)
	local saveInfo = LoadInfo(player)
	return saveInfo
end

function ClimbTower:GetThemeInfo(player, param)
	local saveInfo = LoadInfo(player)
	local themeKey = param.ThemeKey
	local themeList = saveInfo.ThemeList
	local themeInfo = themeList[themeKey]
	if not themeInfo then
		themeInfo = {
			UpgradeCount = 0,
			TowerHeight = ClimbTowerDefine.Game.TowerHeightDefault,
		}
		
		themeList[themeKey] = themeInfo
	end
	
	return themeInfo
end

-----------------------------------------------------------------------------------------------
-- Tower

--function ClimbTower:GetTowerStoreInfo(player)
--	local themeKey = ThemeRequest:GetCurrentTheme(player)
--	local themeData = ConfigManager:SearchData("Theme", "ThemeKey", themeKey)
--	local themeInfo =  ClimbTower:GetThemeInfo(player, { ThemeKey = themeKey })
--	local towerLevel = themeInfo.TowerLevel
--	local towerDataList = ConfigManager:GetDataList("Tower"..themeKey)
--	local isMaxLevel = towerLevel >= #towerDataList
--	local towerData = towerDataList[towerLevel]
--	local nextTowerData = nil
--	if isMaxLevel then
--		nextTowerData = nil
--	else
--		nextTowerData = towerDataList[towerLevel + 1]
--	end
	
--	local info = {
--		Name = themeData.Name,
--		Icon = towerData.Icon,
--		Level = towerLevel,
--		MaxLevel = #towerDataList,
--		IsMaxLevel = isMaxLevel,
--		CostPower = towerData.CostPower,
--		CostCoin = towerData.CostCoin,
--		CostRobux = towerData.CostRobux,
--		ProductKey = towerData.ProductKey,
--	}
	
--	if nextTowerData then
--		info.DisplayLength = nextTowerData.DisplayLength
--	else
--		info.DisplayLength = 0
--	end
	
--	return info
--end

function ClimbTower:UpgradeTower(player, param)
	local themeKey = ThemeRequest:GetCurrentTheme(player)
	local themeData = ConfigManager:SearchData("Theme", "ThemeKey", themeKey)
	local themeInfo =  ClimbTower:GetThemeInfo(player, { ThemeKey = themeKey })
	local towerHeight = themeInfo.TowerHeight
	--local towerDataList = ConfigManager:GetDataList("Tower"..themeKey)
	local isMaxLevel = towerHeight >= themeData.Length
	--local towerData = towerDataList[towerLevel]
	
	if isMaxLevel then
		return {
			Success = false,
			Message = "Max Level",
		}
	end
	
	local accountRequest = require(game.ServerScriptService.ScriptAlias.Account)
	local remainPower = accountRequest:GetPower(player)
	if remainPower <= 0  then
		return {
			Success = false,
			Message = Define.Message.PowerNotEnough,
		}
	end

	accountRequest:SpendPower(player, { Value = remainPower })
	local addHeight = themeData.BuildFactor * remainPower
	local newHeight = towerHeight + addHeight
	if newHeight > themeData.Length then
		newHeight = themeData.Length
	end

	themeInfo.TowerHeight = newHeight
	themeInfo.UpgradeCount += 1
	
	EventManager:Dispatch(EventManager.Define.RefreshTower, { Player = player })
	--EventManager:DispatchToClient(player, EventManager.Define.RefreshTower)

	return {
		Success = true,
		Message = "",
	}
end

-----------------------------------------------------------------------------------------------
-- Dig

function ClimbTower:ResetToDigArea(player)
	local ClimbTowerGameServerHandler = require(game.ServerScriptService.ScriptAlias.ClimbTowerGameServerHandler)
	local result = ClimbTowerGameServerHandler:ResetToDigArea(player)
	return result
end

function ClimbTower:ResetToTower(player)
	local ClimbTowerGameServerHandler = require(game.ServerScriptService.ScriptAlias.ClimbTowerGameServerHandler)
	local result = ClimbTowerGameServerHandler:ResetToTower(player)
	return result
end

function ClimbTower:DigGetPower(player)
	local toolInfo = ToolRequest:GetEquip(player)
	local toolData = ConfigManager:GetData("Tool", toolInfo.ID)
	local equipmentInfo = EquipmentRequest:GetEquip(player)
	local equipmentData = ConfigManager:GetData("Equipment", equipmentInfo.ID)
	local currentPower = AccountRequest:GetPower(player)
	
	if currentPower >= toolData.PowerCapacity then
		return false
	end
	
	local getPowerFactor = PlayerProperty:GetGamePropertyValue(player, PlayerProperty.Define.GET_POWER_FACTOR)
	local getPowerValue = math.round(equipmentData.DigGetPower * getPowerFactor)
	if getPowerValue + currentPower >= toolData.PowerCapacity then
		getPowerValue = toolData.PowerCapacity - currentPower
	end
	
	AccountRequest:AddPower(player, { Value = getPowerValue } )
	return true
end

-----------------------------------------------------------------------------------------------
-- Game

function ClimbTower:Enter(player, param)
	local ClimbTowerGameServerHandler = require(game.ServerScriptService.ScriptAlias.ClimbTowerGameServerHandler)
	local result = ClimbTowerGameServerHandler:Enter(player, param)
	return result
end

function ClimbTower:ArriveEnd(player)
	local ClimbTowerGameServerHandler = require(game.ServerScriptService.ScriptAlias.ClimbTowerGameServerHandler)
	local result = ClimbTowerGameServerHandler:ArriveEnd(player)
	return result
end

function ClimbTower:Slide(player, param)
	local ClimbTowerGameServerHandler = require(game.ServerScriptService.ScriptAlias.ClimbTowerGameServerHandler)
	local result = ClimbTowerGameServerHandler:Slide(player, param)
	return result
end

function ClimbTower:Exit(player)
	local ClimbTowerGameServerHandler = require(game.ServerScriptService.ScriptAlias.ClimbTowerGameServerHandler)
	local result = ClimbTowerGameServerHandler:Exit(player)
	return result
end

function ClimbTower:GetWins(player)
	local ClimbTowerGameServerHandler = require(game.ServerScriptService.ScriptAlias.ClimbTowerGameServerHandler)
	local result = ClimbTowerGameServerHandler:GetWins(player)
	return result
end

function ClimbTower:GetCoin(player)
	local ClimbTowerGameServerHandler = require(game.ServerScriptService.ScriptAlias.ClimbTowerGameServerHandler)
	local result = ClimbTowerGameServerHandler:GetCoin(player)
	return result
end

function ClimbTower:GetDigAreaReward(player, param)
	local id = param.ID
	local data = ConfigManager:GetData("DigAreaReward", id)
	return RewardUtil:GetRewardRequest(player, data)
end

return ClimbTower
