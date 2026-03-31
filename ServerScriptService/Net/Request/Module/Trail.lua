local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local Define = require(game.ReplicatedStorage.Define)

local Trail = {}

local DataTemplate = {
	Pet = {
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

function Trail:Init()
end

function LoadInfo(player)
	local saveInfo = PlayerPrefs:GetModule(player, "Trail")
	return saveInfo
end

function Trail:GetPackageList(player)
	local saveInfo = LoadInfo(player)
	local packageList = saveInfo.PackageList
	local dataList = ConfigManager:GetDataList("Trail")
	if not packageList then
		packageList = {}
		saveInfo.PackageList = packageList
	end

	for index, data in ipairs(dataList) do
		local id = data.ID
		local existInfo = packageList[id]
		-- 创建不存在的信息
		if not existInfo then
			local newInfo = {
				ID = id,
				IsBuy = false,
				IsEquip = false,
				IsLock = false,
			}

			packageList[data.ID] = newInfo
		end
	end
	return packageList
end

function Trail:Buy(player, param)
	local id = param.ID
	local packageList = Trail:GetPackageList(player)
	local info = packageList[id]
	local data = ConfigManager:GetData("Trail", id)
	-- 未解锁
	if info.IsLock then
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
	
	info.IsBuy = true
	AnalyticsManager:Event(player, AnalyticsManager.Define.BuyTrail, "TrailID", data.ID)
	
	return {
		Success = true,
		Message = nil
	}
end

function Trail:Get(player, param)
	local id = param.ID
	local packageList = Trail:GetPackageList(player)
	local info = packageList[id]
	info.IsBuy = true
	return {
		Success = true,
		Message = nil
	}
end

function Trail:Equip(player, param)
	Trail:UnEquip(player)
	local id = param.ID
	local packageList = Trail:GetPackageList(player)
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

	EventManager:Dispatch(EventManager.Define.RefreshTrail, player)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	return true
end

function Trail:UnEquip(player, param)
	local packageList = Trail:GetPackageList(player)
	for _, info in ipairs(packageList) do
		info.IsEquip = false
	end
	EventManager:Dispatch(EventManager.Define.RefreshTrail, player)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	return true
end

function Trail:GetEquip(player)
	local packageList = Trail:GetPackageList(player)
	for _, info in ipairs(packageList) do
		if info.IsEquip then
			return info
		end
	end

	return nil
end

function Trail:CheckExist(player, param)
	local id = param.ID
	local packageList = Trail:GetPackageList(player)
	for _, info in ipairs(packageList) do
		if info.ID == id and info.IsBuy and not info.IsLock then
			return true
		end
	end
	return false
end

return Trail
