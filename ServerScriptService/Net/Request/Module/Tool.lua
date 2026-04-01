local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)

local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)
local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)

local Define = require(game.ReplicatedStorage.Define)

local Tool = {}

local DataTemplate = {
	Tool = {
		PackageList = {
			[1] = {
				ID = 1,
				IsEquip = false,
				IsLock = false,
				IsBuy = true,
			},
		},
	}
}

function Tool:Init()
end

function LoadInfo(player)
	local saveInfo = PlayerPrefs:GetModule(player, "Tool")
	return saveInfo
end

-------------------------------------------------

function Tool:GetPackageList(player)
	local saveInfo = LoadInfo(player)
	local packageList = saveInfo.PackageList
	local dataList = ConfigManager:GetDataList("Tool")
	if not packageList then
		packageList = {}
		saveInfo.PackageList = packageList
	end

	for index, data in ipairs(dataList) do
		local id = data.ID
		local existInfo = packageList[id]
		-- 创建不存在的信息
		if not existInfo then
			local isEquip = false
			local newInfo = {
				ID = id,
				IsBuy = false,
				IsEquip = isEquip,
				IsLock = true,
			}
			
			-- 默认装备
			if newInfo.ID == 1 then
				newInfo.IsEquip = true
				newInfo.IsLock = false
				newInfo.IsBuy = true
			end
			
			if data.BuyOrder == 2 then
				newInfo.IsLock = false
			end

			packageList[data.ID] = newInfo
		end
	end
	return packageList
end

function Tool:GetOwnList(player)
	local result = {}
	local pacakgeList = Tool:GetPackageList(player)
	for index, info in pairs(pacakgeList) do
		if info.IsBuy then
			table.insert(result, info)
		end
	end
	
	return result
end

function Tool:Buy(player, param)
	local id = param.ID
	local packageList = Tool:GetPackageList(player)
	local info = packageList[id]
	local data = ConfigManager:GetData("Tool", id)
	-- 未解锁
	if info.IsLock and data.CostRobux <= 0 then
		return {
			Success = false,
			Message = Define.Message.Locked
		}
	end
	
	-- 已购买
	if info.IsBuy then
		return {
			Success = false,
			Message = Define.Message.Baught
		}
	end
	
	-- 检查是否获得前置物品
	local buyOrder = data.BuyOrder
	if buyOrder > 1 then
		local previousOrder = buyOrder - 1
		local previousData = ConfigManager:SearchData("Tool", "BuyOrder", previousOrder)
		if previousData then
			local previousInfo = packageList[previousData.ID]
			if not previousInfo.IsBuy then
				return {
					Success = false,
					Message = Define.Message.PreviousLocked
				}
			end
		end
	end
	
	if data.CostCoin > 0 then
		local coinRemain = NetServer:RequireModule("Account"):GetCoin(player)
		if coinRemain < data.CostCoin then
			return {
				Success = false,
				Message = Define.Message.CoinNotEnough
			}
		end

		NetServer:RequireModule("Account"):SpendCoin(player, {Value = data.CostCoin })
	end
	
	if data.CostWins > 0 then
		local winsRemain = NetServer:RequireModule("Account"):GetWins(player)
		if winsRemain < data.CostWins then
			return {
				Success = false,
				Message = Define.Message.WinsNotEnough
			}
		end

		NetServer:RequireModule("Account"):SpendWins(player, {Value = data.CostWins })
	end
	
	info.IsLock = false
	info.IsBuy = true
	
	-- 有购买顺序配置，则解锁下一个可购买物品
	if buyOrder > 1 then
		local nextBuyOrder = buyOrder + 1
		local nextData = ConfigManager:SearchData("Tool", "BuyOrder", nextBuyOrder)
		if nextData then
			local nextInfo = packageList[nextData.ID]
			nextInfo.IsLock = false
		end
	end
	
	AnalyticsManager:Event(player, AnalyticsManager.Define.BuyTool, "ToolID", data.ID)
	
	PlayerRecord:AddValue(player, PlayerRecord.Define.TotalGetTool, 1)
	EventManager:Dispatch(EventManager.Define.QuestGetTool, {
		Player = player,
		Value = 1,
	})
	
	EventManager:Dispatch(EventManager.Define.GetTool, {
		Player = player,
		ID = id,
	})
	
	return {
		Success = true,
		Message = nil
	}
end

function Tool:Get(player, param)
	local id = param.ID
	local packageList = Tool:GetPackageList(player)
	local info = packageList[id]
	
	info.IsLock = false
	info.IsBuy = true
	
	PlayerRecord:AddValue(player, PlayerRecord.Define.TotalGetTool, 1)
	EventManager:Dispatch(EventManager.Define.QuestGetTool, {
		Player = player,
		Value = 1,
	})
	
	EventManager:Dispatch(EventManager.Define.GetTool, {
		Player = player,
		ID = id,
	})

	return {
		Success = true,
		Message = nil
	}
end

function Tool:Equip(player, param)
	Tool:UnEquip(player)
	local id = param.ID
	local packageList = Tool:GetPackageList(player)
	local info = packageList[id]
	if info.ID == param.ID then
		-- 未解锁
		if info.IsLock then
			return false
		end
		-- 未购买
		if not info.IsBuy then
			return false
		end

		info.IsEquip = true
	end
	
	EventManager:Dispatch(EventManager.Define.RefreshTool, player)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	return true
end

function Tool:UnEquip(player, param)
	local packageList = Tool:GetPackageList(player)
	for _, info in ipairs(packageList) do
		info.IsEquip = false
	end
	EventManager:Dispatch(EventManager.Define.RefreshTool, player)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	return true
end

function Tool:GetEquip(player)
	local packageList = Tool:GetPackageList(player)
	for _, info in ipairs(packageList) do
		if info.IsEquip then
			return info
		end
	end

	return nil
end

function Tool:CheckExist(player, param)
	local id = param.ID
	local packageList = Tool:GetPackageList(player)
	for _, info in ipairs(packageList) do
		if info.ID == id and info.IsBuy and not info.IsLock then
			return true
		end
	end
	return false
end

return Tool
