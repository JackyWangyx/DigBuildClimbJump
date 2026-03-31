local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)

local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)
local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local ToolRequest = require(game.ServerScriptService.ScriptAlias.Tool)
local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)

local Define = require(game.ReplicatedStorage.Define)

local Animal = {}

local AnimalDataTemplate = {
	Animal = {
		PackageList = {
			{
				ID = 1,
				InstanceID = "guid",
				IsEquip = false,
				IsLock = false,
			},
		},
		PackageLevel = 1,			-- 背包等级，按表格提供容量
		PackageAdditional = 0,		-- 额外背包容量，特殊方式获得
		--EquipLevel = 1,			-- 装备栏位，按表格提供容量
		EquipAdditional = 0,		-- 额外装备容量，特殊方式获得
	}
}

function LoadInfo(player)
	local saveInfo = PlayerPrefs:GetModule(player, "Animal")
	return saveInfo
end

-- Get Info
function Animal:GetPackageList(player)
	local saveInfo = LoadInfo(player)
	local packageList = saveInfo.PackageList
	if not packageList then
		packageList = {}
		saveInfo.PackageList = packageList
		-- Default
		--Animal:Add(player, { ID = 1 })
		--local firstAnimal = packageList[1]
		--firstAnimal.IsEquip = true
	end
	
	return packageList
end

function Animal:GetAnimalInfo(player, param)
	local instanceID = param.InstanceID
	local packageList = Animal:GetPackageList(player)
	for _, animalInfo in ipairs(packageList) do
		if animalInfo.InstanceID == instanceID  then
			return animalInfo
		end
	end

	return nil
end

function Animal:GetSameAnimalList(player, param)
	local instanceID = param.InstanceID
	local saveInfo = LoadInfo(player)
	local result = {}

	local srcAnimalInfo = Animal:GetAnimalInfo(player, param)
	if not srcAnimalInfo then
		return result
	end

	local packageList = Animal:GetPackageList(player)
	for _, animalInfo in ipairs(packageList) do
		if -- animal.InstanceID ~= instanceID 
			animalInfo.ID == srcAnimalInfo.ID 
			and not animalInfo.IsLock
			and not animalInfo.IsEquip
		then
			table.insert(result, animalInfo)
		end
	end

	return result
end

-- Add / Remove

function Animal:Buy(player, param)
	local id = param.ID
	
	if not Animal:CheckPackage(player) then
		return {
			Success = false,
			Message = Define.Message.PackageFull
		}
	end
	
	local data = ConfigManager:GetData("Animal", id)
	if data.CostCoin > 0 then
		local coinRemain = NetServer:RequireModule("Account"):GetCoin(player)
		if coinRemain < data.CostCoin then
			return {
				Success = false,
				Message = Define.Message.CoinNotEnough
			}
		end
	end
	
	if data.CostWins > 0 then
		local winsRemain = NetServer:RequireModule("Account"):GetWins(player)
		if winsRemain < data.CostWins then
			return {
				Success = false,
				Message = Define.Message.WinsNotEnough
			}
		end
	end

	local result = Animal:Add(player, param)
	if result then
		NetServer:RequireModule("Account"):SpendCoin(player, {Value = data.CostCoin })	
		NetServer:RequireModule("Account"):SpendWins(player, {Value = data.CostWins })	
		AnalyticsManager:Event(player, AnalyticsManager.Define.BuyAnimal, "AnimalID", data.ID)

		return {
			Success = true,
			Message = nil
		}
	else
		return {
			Success = false,
			Message = nil,
		}
	end
end

function Animal:Add(player, param)
	-- 检查背包容量
	if not Animal:CheckPackage(player) then
		return false
	end
	
	local animalID = param.ID
	local animalData = ConfigManager:GetData("Animal", animalID)
	if not animalData then
		warn("[Server]", "Animal config not found!", animalID)
		return false
	end

	local animalInfo = {
		ID = animalID,
		InstanceID = Util:NewGuid(),
		IsLock = false,
		IsEquip = false,
	}
	
	local packageList = Animal:GetPackageList(player)
	table.insert(packageList, animalInfo)
	
	PlayerRecord:AddValue(player, PlayerRecord.Define.TotalGetAnimal, 1)
	EventManager:Dispatch(EventManager.Define.QuestGetAnimal, {
		Player = player,
		Value = 1,
	})

	EventManager:DispatchToClient(player, EventManager.Define.RefreshAnimal)
	EventManager:Dispatch(EventManager.Define.GetAnimal, {
		Player = player,
		ID = animalID,
	})
	
	return true
end

function Animal:Delete(player, param)
	local instanceID = param.InstanceID
	local packageList = Animal:GetPackageList(player)
	Util:ListRemoveWithCondition(packageList, function(info)
		return info.InstanceID == instanceID
	end)
	
	EventManager:Dispatch(EventManager.Define.RefreshAnimal, player)
	EventManager:DispatchToClient(player, EventManager.Define.RefreshAnimal)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	
	return true
end

function Animal:DeleteAll(player, param)
	local instanceIDList = param.InstanceIDList
	local packageList = Animal:GetPackageList(player)
	for _, instanceID in ipairs(instanceIDList) do
		Util:ListRemoveWithCondition(packageList, function(info)
			return info.InstanceID == instanceID
		end)
	end
	
	EventManager:Dispatch(EventManager.Define.RefreshAnimal, player)
	EventManager:DispatchToClient(player, EventManager.Define.RefreshAnimal)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	
	return true
end

-- Package Max

function Animal:GetPackageMax(player)
	local saveInfo = LoadInfo(player)
	local packageData = ConfigManager:GetData("AnimalPackage", saveInfo.PackageLevel or 1)
	local dataValue = packageData.Value
	local additionalValue = saveInfo.PackageAdditional or 0
	local result = dataValue + additionalValue
	return result
end

function Animal:GetPackageCount(player)
	local saveInfo = LoadInfo(player)
	local value = 0
	if saveInfo.PackageList then
		value = #saveInfo.PackageList
	end
	return value
end

function Animal:CheckPackage(player, param)
	local value = 1
	if param then
		value = param.Value or 1
	end
	local max = Animal:GetPackageMax(player)
	local count = Animal:GetPackageCount(player) + value
	return count <= max
end

function Animal:IsPackageMaxLevel(player)
	local saveInfo = LoadInfo(player)
	local currentLevel = saveInfo.PackageLevel or 1
	local nextData = ConfigManager:GetData("AnimalPackage", currentLevel + 1)
	return nextData == nil
end

function Animal:AddPackageMax(player)
	local saveInfo = LoadInfo(player)
	local currentLevel = saveInfo.PackageLevel or 1
	local nextData = ConfigManager:GetData("AnimalPackage", currentLevel + 1)
	if not nextData then return false end
	saveInfo.PackageLevel = currentLevel + 1
	return true
end

function Animal:AddPackageAdditional(player, param)
	local saveInfo = LoadInfo(player)
	local value = saveInfo.PackageAdditional or 0
	value += param.Value or 1
	saveInfo.PackageAdditional = value
	return true
end

-- Lock
function Animal:Lock(player, param)
	local instanceID = param.InstanceID
	local animalInfo = Animal:GetAnimalInfo(player, param)
	if not animalInfo then return false end
	if animalInfo.IsLock then return false end
	animalInfo.IsLock = true
	return true
end

function Animal:UnLock(player, param)
	local instanceID = param.InstanceID
	local animalInfo = Animal:GetAnimalInfo(player, param)
	if not animalInfo then return false end
	if not animalInfo.IsLock then return false end
	animalInfo.IsLock = false
	return true
end

-- Equip
function Animal:Equip(player, param)
	if not Animal:CheckCanEquip(player) then return false end
	local instanceID = param.InstanceID
	local animalInfo = Animal:GetAnimalInfo(player, param)
	if not animalInfo then return false end
	if animalInfo.IsEquip then return false end
	animalInfo.IsEquip = true
	EventManager:Dispatch(EventManager.Define.RefreshAnimal, player)
	EventManager:DispatchToClient(player, EventManager.Define.RefreshAnimal)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	return true
end

function Animal:UnEquip(player, param)
	local instanceID = param.InstanceID
	local animalInfo = Animal:GetAnimalInfo(player, param)
	if not animalInfo then return false end
	if not animalInfo.IsEquip then return false end
	animalInfo.IsEquip = false
	EventManager:Dispatch(EventManager.Define.RefreshAnimal, player)
	EventManager:DispatchToClient(player, EventManager.Define.RefreshAnimal)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	return true
end

function Animal:GetEquipList(player)
	local result = {}
	local packageList = Animal:GetPackageList(player)
	local equipMax = Animal:GetEquipMax(player)
	local count = 0
	for _, animalInfo in ipairs(packageList) do
		if animalInfo.IsEquip then
			if count < equipMax then
				table.insert(result, animalInfo)
				count += 1
			else
				animalInfo.IsEquip = false
			end
		end
	end
	
	return result
end

function Animal:GetEquipMax(player)
	local saveInfo = LoadInfo(player)
	local toolInfo = ToolRequest:GetEquip(player)
	local toolData = ConfigManager:GetData("Tool", toolInfo.ID)
	local dataValue = toolData.AnimalCapacity
	local additionalValue = saveInfo.EquipAdditional or 0
	local result = dataValue + additionalValue
	return result
end

function Animal:GetEquipCount(player)
	local packageList = Animal:GetPackageList(player)
	local count = Util:ListCount(packageList, function(animal)
		return animal.IsEquip
	end)
	return count
end

function Animal:CheckCanEquip(player)
	local max = Animal:GetEquipMax(player)
	local count = Animal:GetEquipCount(player)
	return count < max
end

function Animal:AddEquipAdditional(player, param)
	local saveInfo = LoadInfo(player)
	local value = saveInfo.EquipAdditional or 0
	value += param.Value or 1
	saveInfo.EquipAdditional = value
	return true
end

function Animal:UnEquipAll(player)
	local packageList = Animal:GetPackageList(player)
	for _, animal in ipairs(packageList) do
		animal.IsEquip = false
	end
	
	EventManager:Dispatch(EventManager.Define.RefreshAnimal, player)
	EventManager:DispatchToClient(player, EventManager.Define.RefreshAnimal)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	
	return true
end

function Animal:EquipBest(player, param)
	local packageList = Animal:GetPackageList(player)
	Animal:UnEquipAll(player)
	local equipMax = Animal:GetEquipMax(player)
	local equipInstanceIDList = param.InstanceIDList
	local count = 0
	for _, animal in ipairs(packageList) do
		local requireEquip = Util:ListContains(equipInstanceIDList, animal.InstanceID)
		if requireEquip then
			animal.IsEquip = true
			count = count + 1
			if count >= equipMax then
				break
			end
		else
			animal.IsEquip = false
		end
	end
	
	EventManager:Dispatch(EventManager.Define.RefreshAnimal, player)
	EventManager:DispatchToClient(player, EventManager.Define.RefreshAnimal)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	
	return true
end

return Animal
