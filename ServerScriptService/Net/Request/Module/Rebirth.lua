local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local PlayerProperty = require(game.ServerScriptService.ScriptAlias.PlayerProperty)
local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local AccountRequest = require(game.ServerScriptService.ScriptAlias.Account)

local Define = require(game.ReplicatedStorage.Define)

local Rebirth = {}

local DataSample = {
	Rebirth = {
		Level = 1,
		AutoRebirth = false,
	}
}

function Rebirth:Init() 
end

function LoadInfo(player)
	local saveInfo = PlayerPrefs:GetModule(player, "Rebirth")
	if not saveInfo.Level then
		saveInfo.Level = 1
	end
	return saveInfo
end

function Rebirth:GetInfo(player)
	local saveInfo = LoadInfo(player)
	local currentData = ConfigManager:GetData("Rebirth", saveInfo.Level)
	return currentData
end

function Rebirth:GetLevel(player)
	local info = Rebirth:GetInfo(player)
	local level = info.ID - 1
	return level
end

function Rebirth:CheckCanRebirth(player)
	local saveInfo = LoadInfo(player)
	local nextData = ConfigManager:GetData("Rebirth", saveInfo.Level + 1)
	if not nextData then
		return false
	end
	
	local currentData = ConfigManager:GetData("Rebirth", saveInfo.Level)
	local coin = AccountRequest:GetCoin(player)
	if coin < currentData.CostCoin then
		return false
	end
	
	return true
end

function Rebirth:GetUIInfo(player)
	local saveInfo = LoadInfo(player)
	local currentData = ConfigManager:GetData("Rebirth", saveInfo.Level)
	local nextData = ConfigManager:GetData("Rebirth", saveInfo.Level + 1)
	if not nextData then
		return nil
	end
	
	local coin = AccountRequest:GetCoin(player)
	local progress = coin * 1 / currentData.CostCoin
	if progress > 1 then progress = 1 end
	local result = {
		CurrentRebirth = saveInfo.Level - 1,
		NextRebirth = saveInfo.Level,
		CurrentDisplayGetPowerFactor = currentData.DisplayGetPowerFactor,
		NextDisplayGetPowerFactor = nextData.DisplayGetPowerFactor,
		CoinValue = coin,
		RequireCoinValue = currentData.CostCoin,
		CoinProgress = progress,
		MaxRebirth = saveInfo.Level,
		AutoRebirth = saveInfo.AutoRebirth or false
	}
	
	return result
end

function Rebirth:GetAuto(player)
	local saveInfo = LoadInfo(player)
	if saveInfo.AutoRebirth == nil then
		saveInfo.AutoRebirth = false
	end
	local auto = saveInfo.AutoRebirth
	return auto
end

function Rebirth:SwitchAuto(player)
	local iapRequest = require(game.ServerScriptService.ScriptAlias.IAP)
	local hasGamePass = iapRequest:CheckHasGamePass(player, { ProductKey = "AutoRebirth" })
	if not hasGamePass then
		return false
	end
	
	local saveInfo = LoadInfo(player)
	local auto = Rebirth:GetAuto(player)
	saveInfo.AutoRebirth = not auto
	local rebirthHandler = require(game.ServerScriptService.ScriptAlias.AutoRebirthHandler)
	if saveInfo.AutoRebirth then
		rebirthHandler:AddPlayer(player)
	else
		rebirthHandler:RemovePlayer(player)
	end
	
	return true
end

function Rebirth:RebirthManual(player)
	local saveInfo = LoadInfo(player)
	local nextData = ConfigManager:GetData("Rebirth", saveInfo.Level + 1)
	if not nextData then
		return {
			Success = false,
			Message = "",
		}
	end
	
	local currentData = ConfigManager:GetData("Rebirth", saveInfo.Level)
	local coin = AccountRequest:GetCoin(player)
	if coin < currentData.CostCoin then
		return {
			Success = false,
			Message = Define.Message.CoinNotEnough,
		}
	end
	
	AccountRequest:SpendCoin(player, { Value = currentData.CostCoin })
	saveInfo.Level += 1
	local training = require(game.ServerScriptService.ScriptAlias.Training)
	training:SpendPower(player, { Value = training:GetPower(player) })
	
	AnalyticsManager:Event(player, AnalyticsManager.Define.Rebirth, "Level", saveInfo.Level)
	AnalyticsManager:Funnel(player, AnalyticsManager.Define.Rebirth, saveInfo.Level - 1, "Rebirth_"..tostring(saveInfo.Level - 1))
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	
	PlayerRecord:AddValue(player, PlayerRecord.Define.TotalRebirth, 1)
	EventManager:Dispatch(EventManager.Define.QuestRebirth, {
		Player = player,
		Value = 1,
	})
	
	return {
		Success = true,
		Message = "",
	}
end

function Rebirth:RebirthSkip(player)
	local saveInfo = LoadInfo(player)
	local nextData = ConfigManager:GetData("Rebirth", saveInfo.Level + 1)
	if not nextData then
		return {
			Success = false,
			Message = "",
		}
	end

	local currentData = ConfigManager:GetData("Rebirth", saveInfo.Level)
	saveInfo.Level += 1
	local training = require(game.ServerScriptService.ScriptAlias.Training)
	training:SpendPower(player, { Value = training:GetPower(player) })
	
	AnalyticsManager:Event(player, AnalyticsManager.Define.Rebirth, "Level", saveInfo.Level)
	AnalyticsManager:Funnel(player, AnalyticsManager.Define.Rebirth, saveInfo.Level - 1, "Rebirth_"..tostring(saveInfo.Level - 1))
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)

	PlayerRecord:AddValue(player, PlayerRecord.Define.TotalRebirth, 1)
	EventManager:Dispatch(EventManager.Define.QuestRebirth, {
		Player = player,
		Value = 1,
	})

	return {
		Success = true,
		Message = "",
	}
end

function Rebirth:RebirthAuto(player)
	while Rebirth:CheckCanRebirth(player) do
		local result = Rebirth:RebirthManual(player)
		if not result.Success then
			break
		end
		task.wait()
	end
	
	EventManager:DispatchToClient(player, EventManager.Define.RefreshRebirth)
	return {
		Success = true,
		Message = "",
	}
end

return Rebirth