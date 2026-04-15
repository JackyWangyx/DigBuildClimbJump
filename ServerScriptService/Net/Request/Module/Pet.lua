local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)

local Define = require(game.ReplicatedStorage.Define)

local Pet = {}

local PetDataTemplate = {
	Pet = {
		PackageList = {
			{
				ID = 1,
				InstanceID = "guid",
				IsEquip = false,
				IsLock = false,
				UpgradeLevel = 1,
				UpgradeFactor = 1.0,
			},
		},
		PackageLevel = 1,			-- 背包等级，按表格提供容量
		PackageAdditional = 0,		-- 额外背包容量，特殊方式获得
		EquipLevel = 1,				-- 装备栏位，按表格提供容量
		EquipAdditional = 0,		-- 额外装备容量，特殊方式获得
	}
}

function LoadInfo(player)
	local saveInfo = PlayerPrefs:GetModule(player, "Pet")
	return saveInfo
end

----------------------------------------------------------------------------------------------------
-- Get Info

function Pet:GetPackageList(player)
	local saveInfo = LoadInfo(player)
	local packageList = saveInfo.PackageList
	if not packageList then
		packageList = {}
		saveInfo.PackageList = packageList
	end
	
	for _, info in ipairs(packageList) do
		if info.UpgradeFactor == nil then
			local data = ConfigManager:SearchData("PetUpgrade", "PetID", info.ID, "Level", info.UpgradeLevel or 1)
			if data then
				info.UpgradeFactor = data.Factor or 1
			else
				info.UpgradeFactor = 1
			end	
		end
	end
	
	return packageList
end

function Pet:GetMaxCoinFactor(player)
	local packageList = Pet:GetPackageList(player)
	local maxGetCoinFactor = 0
	for _, petInfo in ipairs(packageList) do
		local data = ConfigManager:GetData("Pet", petInfo.ID)
		if data == nil then
			warn("[Pet] Pet Data not found : " .. petInfo.ID)
			continue
		end
		
		local getCoinFactor = data.GetCoinFactor1 or 0
		local upgradeFactor = petInfo.UpgradeFactor or 1
		local coinFactor = getCoinFactor * upgradeFactor
		if coinFactor > maxGetCoinFactor then
			maxGetCoinFactor = coinFactor
		end
	end
	
	return maxGetCoinFactor
end

function Pet:GetPetInfo(player, param)
	local instanceID = param.InstanceID
	local packageList = Pet:GetPackageList(player)
	for _, petInfo in ipairs(packageList) do
		if petInfo.InstanceID == instanceID  then
			return petInfo
		end
	end

	return nil
end

function Pet:GetSamePetList(player, param)
	local instanceID = param.InstanceID
	local saveInfo = LoadInfo(player)
	local result = {}

	local srcPetInfo = Pet:GetPetInfo(player, param)
	if not srcPetInfo then
		return result
	end

	local packageList = Pet:GetPackageList(player)
	for _, petInfo in ipairs(packageList) do
		if -- pet.InstanceID ~= instanceID 
			petInfo.ID == srcPetInfo.ID 
			and petInfo.UpgradeLevel == srcPetInfo.UpgradeLevel
			and not petInfo.IsLock
			and not petInfo.IsEquip
		then
			table.insert(result, petInfo)
		end
	end

	return result
end

----------------------------------------------------------------------------------------------------
-- Add / Delete

function Pet:Add(player, param)
	-- 检查背包容量
	if not Pet:CheckPackage(player) then
		return false
	end
	
	local petID = param.ID
	local petData = ConfigManager:GetData("Pet", petID)
	if not petData then
		warn("[Server]", "Pet config not found!", petID)
		return false
	end
	local petUpgradeLevel = param.UpgradeLevel or 1
	local petInfo = {
		ID = petID,
		InstanceID = Util:NewGuid(),
		IsLock = false,
		IsEquip = false,
		UpgradeLevel = petUpgradeLevel
	}
	
	local packageList = Pet:GetPackageList(player)
	table.insert(packageList, petInfo)

	Pet:EquipBest(player)
	
	PlayerRecord:AddValue(player, PlayerRecord.Define.TotalGetPet, 1)
	EventManager:Dispatch(EventManager.Define.QuestGetPet, {
		Player = player,
		Value = 1,
	})
	
	EventManager:DispatchToClient(player, EventManager.Define.RefreshPet)
	EventManager:Dispatch(EventManager.Define.GetPet, {
		Player = player,
		ID = petID,
	})
	
	return true
end

function Pet:Delete(player, param)
	local instanceID = param.InstanceID
	local packageList = Pet:GetPackageList(player)
	Util:ListRemoveWithCondition(packageList, function(info)
		return info.InstanceID == instanceID
	end)
	
	EventManager:Dispatch(EventManager.Define.RefreshPet, player)
	EventManager:DispatchToClient(player, EventManager.Define.RefreshPet)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	
	return true
end

function Pet:DeleteAll(player, param)
	local instanceIDList = param.InstanceIDList
	local packageList = Pet:GetPackageList(player)
	for _, instanceID in ipairs(instanceIDList) do
		Util:ListRemoveWithCondition(packageList, function(info)
			return info.InstanceID == instanceID
		end)
	end

	EventManager:Dispatch(EventManager.Define.RefreshPet, player)
	EventManager:DispatchToClient(player, EventManager.Define.RefreshPet)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	
	return true
end

----------------------------------------------------------------------------------------------------
-- Package

function Pet:GetPackageMax(player)
	local saveInfo = LoadInfo(player)
	local packageData = ConfigManager:GetData("PetPackage", saveInfo.PackageLevel or 1)
	local dataValue = packageData.Value
	local additionalValue = saveInfo.PackageAdditional or 0
	local result = dataValue + additionalValue
	return result
end

function Pet:GetPackageCount(player)
	local saveInfo = LoadInfo(player)
	local value = 0
	if saveInfo.PackageList then
		value = #saveInfo.PackageList
	end
	return value
end

function Pet:CheckPackage(player, param)
	local value = 1
	if param then
		value = param.Value or 1
	end
	local max = Pet:GetPackageMax(player)
	local count = Pet:GetPackageCount(player) + value
	return count <= max
end

function Pet:IsPackageMaxLevel(player)
	local saveInfo = LoadInfo(player)
	local currentLevel = saveInfo.PackageLevel or 1
	local nextData = ConfigManager:GetData("PetPackage", currentLevel + 1)
	return nextData == nil
end

function Pet:AddPackageMax(player)
	local saveInfo = LoadInfo(player)
	local currentLevel = saveInfo.PackageLevel or 1
	local nextData = ConfigManager:GetData("PetPackage", currentLevel + 1)
	if not nextData then return false end
	saveInfo.PackageLevel = currentLevel + 1
	return true
end

function Pet:AddPackageAdditional(player, param)
	local saveInfo = LoadInfo(player)
	local value = saveInfo.PackageAdditional or 0
	value += param.Value or 1
	saveInfo.PackageAdditional = value
	return true
end

----------------------------------------------------------------------------------------------------
-- Craft

function Pet:Craft(player, param)
	local canCraft = Pet:CheckCanCraft(player, param)
	if not canCraft then return false end
	local petList = Pet:GetSamePetList(player, param)
	local petUpgradeLevel = petList[1].UpgradeLevel
	local currentPetID = petList[1].ID
	local nextPetData = ConfigManager:SearchData("PetCraft", "SourceID", currentPetID)
	local saveInfo = LoadInfo(player)
	local count = 0
	for index, pet in petList do
		Util:ListRemoveWithCondition(saveInfo.PackageList, function(p) return p.InstanceID == pet.InstanceID end)
		count = count + 1
		if count >= 3 then break end
	end
	
	local result = Pet:Add(player, {
		ID = nextPetData.TargetID,
		UpgradeLevel = petUpgradeLevel
	})
	
	if result then
		EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
		return true
	else
		return false
	end
end

function Pet:CraftRobux(player, param)
	local petInfo = Pet:GetPetInfo(player, param)
	local currentPetID = petInfo.ID
	local petUpgradeLevel = petInfo.UpgradeLevel
	local nextPetData = ConfigManager:SearchData("PetCraft", "SourceID", currentPetID)
	-- 已满级
	if not nextPetData then
		return false
	end
	
	local saveInfo = LoadInfo(player)
	Util:ListRemoveWithCondition(saveInfo.PackageList, function(p) return p.InstanceID == petInfo.InstanceID end)
	local result = Pet:Add(player, {
		ID = nextPetData.TargetID,
		UpgradeLevel = petUpgradeLevel
	})
	
	if result then
		EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
		return true
	else
		return false
	end
end

function Pet:CraftAll(player)
	local find = false
	repeat
		find = false
		local findPetInstanceID = nil
		local packageList = Pet:GetPackageList(player)
		for _, pet in ipairs(packageList) do
			local canCraft = Pet:CheckCanCraft(player, { InstanceID = pet.InstanceID })
			if canCraft then
				find = true
				findPetInstanceID = pet.InstanceID
				break
			end
		end
		
		if find then
			local result = Pet:Craft(player, { InstanceID = findPetInstanceID })
		end
	until not find
	
	return true
end

function Pet:CheckCanCraft(player, param)
	local petList = Pet:GetSamePetList(player, param)
	-- 数量不足
	if #petList < 3 then
		return false
	end

	local isMaxLevel = Pet:CheckCraftMaxLevel(player, param)
	if isMaxLevel then return false end	
	return true
end

function Pet:CheckCraftMaxLevel(player, param)
	local petInfo = Pet:GetPetInfo(player, param)
	if not petInfo then return true end
	local currentPetID = petInfo.ID
	local nextPetData = ConfigManager:SearchData("PetCraft", "SourceID", currentPetID)
	if not nextPetData then
		return true
	end
	return false
end

----------------------------------------------------------------------------------------------------
-- Lock

function Pet:Lock(player, param)
	local instanceID = param.InstanceID
	local petInfo = Pet:GetPetInfo(player, param)
	if not petInfo then return false end
	if petInfo.IsLock then return false end
	petInfo.IsLock = true
	return true
end

function Pet:UnLock(player, param)
	local instanceID = param.InstanceID
	local petInfo = Pet:GetPetInfo(player, param)
	if not petInfo then return false end
	if not petInfo.IsLock then return false end
	petInfo.IsLock = false
	return true
end

----------------------------------------------------------------------------------------------------
-- Equip

function Pet:Equip(player, param)
	if not Pet:CheckCanEquip(player) then return false end
	local instanceID = param.InstanceID
	local petInfo = Pet:GetPetInfo(player, param)
	if not petInfo then return false end
	if petInfo.IsEquip then return false end
	petInfo.IsEquip = true
	EventManager:Dispatch(EventManager.Define.RefreshPet, player)
	EventManager:DispatchToClient(player, EventManager.Define.RefreshPet)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	return true
end

function Pet:UnEquip(player, param)
	local instanceID = param.InstanceID
	local petInfo = Pet:GetPetInfo(player, param)
	if not petInfo then return false end
	if not petInfo.IsEquip then return false end
	petInfo.IsEquip = false
	EventManager:Dispatch(EventManager.Define.RefreshPet, player)
	EventManager:DispatchToClient(player, EventManager.Define.RefreshPet)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	return true
end

function Pet:GetEquipList(player)
	local result = {}
	local packageList = Pet:GetPackageList(player)
	for _, pet in ipairs(packageList) do
		if pet.IsEquip then
			table.insert(result, pet)
		end
	end
	return result
end

function Pet:GetEquipMax(player)
	local saveInfo = LoadInfo(player)
	local packageData = ConfigManager:GetData("PetEquip", saveInfo.EquipLevel or 1)
	local dataValue = packageData.Value
	local additionalValue = saveInfo.EquipAdditional or 0
	local result = dataValue + additionalValue
	
	local quest = require(game.ServerScriptService.ScriptAlias.Quest)
	local hasPass = quest:CheckSeasonPass(player)
	if hasPass then
		result += Define.Quest.AdditionalPetEquip
	end
	
	return result
end

function Pet:GetEquipCount(player)
	local packageList = Pet:GetPackageList(player)
	local count = Util:ListCount(packageList, function(pet)
		return pet.IsEquip
	end)
	return count
end

function Pet:CheckCanEquip(player)
	local max = Pet:GetEquipMax(player)
	local count = Pet:GetEquipCount(player)
	return count < max
end

function Pet:IsEquipMaxLevel(player)
	local saveInfo = LoadInfo(player)
	local currentLevel = saveInfo.EquipLevel or 1
	local nextData = ConfigManager:GetData("PetEquip", currentLevel + 1)
	return nextData == nil
end

function Pet:AddEquipMax(player)
	local saveInfo = LoadInfo(player)
	local currentLevel = saveInfo.EquipLevel or 1
	local nextData = ConfigManager:GetData("PetEquip", currentLevel + 1)
	if not nextData then return false end
	saveInfo.EquipLevel = currentLevel + 1
	return true
end

function Pet:AddEquipAdditional(player, param)
	local saveInfo = LoadInfo(player)
	local value = saveInfo.EquipAdditional or 0
	value += param.Value or 1
	saveInfo.EquipAdditional = value
	return true
end

function Pet:UnEquipAll(player)
	local packageList = Pet:GetPackageList(player)
	for _, pet in ipairs(packageList) do
		pet.IsEquip = false
	end
	
	EventManager:Dispatch(EventManager.Define.RefreshPet, player)
	EventManager:DispatchToClient(player, EventManager.Define.RefreshPet)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	
	return true
end

function Pet:EquipBest(player)
	local packageList = Pet:GetPackageList(player)
	Pet:UnEquipAll(player)
	local equipMax = Pet:GetEquipMax(player)
	
	local infoList = Pet:GetPackageList(player)
	
	local maxGetCoinFactor1 = 0
	for _, info in pairs(infoList) do
		local data = ConfigManager:GetData("Pet", info.ID)
		local upgradehData = ConfigManager:SearchData("PetUpgrade", "PetID", info.ID, "Level", info.UpgradeLevel)
		info.GetCoinFactor1 = data.GetCoinFactor1 * upgradehData.Factor
		if info.GetCoinFactor1 > maxGetCoinFactor1 then
			maxGetCoinFactor1 = info.GetCoinFactor1
		end
	end
	
	for _, info in pairs(infoList) do
		local data = ConfigManager:GetData("Pet", info.ID)
		if data.MaxExistGetCoinFactor1 > 0 then
			info.GetCoinFactor1 = maxGetCoinFactor1 * data.MaxExistGetCoinFactor1
		end
	end

	infoList = Util:ListSort(infoList, {
		function(info) return -info.GetCoinFactor1 end
	})

	local idList = {}
	local equipInfoList = Util:ListFindMany(infoList, equipMax)
	for _, info in pairs(equipInfoList) do
		table.insert(idList, info.InstanceID)
	end
	
	local count = 0
	for _, pet in ipairs(packageList) do
		local requireEquip = Util:ListContains(idList, pet.InstanceID)
		if requireEquip then
			pet.IsEquip = true
			count = count + 1
			if count >= equipMax then
				break
			end
		else
			pet.IsEquip = false
		end
	end
	
	EventManager:Dispatch(EventManager.Define.RefreshPet, player)
	EventManager:DispatchToClient(player, EventManager.Define.RefreshPet)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	return true
end

----------------------------------------------------------------------------------------------------
-- Upgrade

function Pet:CheckCanUpgrade(player, param)
	local instanceID = param.InstanceID
	local info = Pet:GetPetInfo(player, param)
	if info == nil then return false end
	local upgradeLevel = info.UpgradeLevel
	return upgradeLevel < 3
end

function Pet:Upgrade(player, param)
	local result = {
		PetInfo = nil,
	}
	
	local instanceIDList = param.InstanceIDList
	if #instanceIDList == 0 then 
		result.Result = false
		return result
	end
	
	-- 抽奖
	local successFactor = #instanceIDList * 0.2
	if successFactor > 1 then successFactor = 1 end
	math.randomseed(os.time())
	local randValue = math.random()
	local success = successFactor >= randValue
	local saveInfo = LoadInfo(player)
	
	-- 失败
	if not success then
		result.Result = false
		Pet:DeleteAll(player, { InstanceIDList = instanceIDList })
		return result
	end
	
	if not Pet:CheckCanUpgrade(player, {InstanceID = instanceIDList[1]})  then 
		result.Result = false
		return result
	end
	
	-- 成功
	local targetLevel = 1
	for index, instanceID in ipairs(instanceIDList) do
		if index == 1 then
			local petInfo = Pet:GetPetInfo(player, {InstanceID = instanceID})
			petInfo.UpgradeLevel = petInfo.UpgradeLevel + 1
			targetLevel = petInfo.UpgradeLevel
			local data = ConfigManager:SearchData("PetUpgrade", "PetID", petInfo.ID, "Level", petInfo.UpgradeLevel or 1)
			petInfo.UpgradeFactor = data.Factor
			result.PetInfo = petInfo
		else
			Pet:Delete(player, {InstanceID = instanceID})
		end
	end

	result.Result = true

	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	PlayerRecord:AddValue(player, PlayerRecord.Define.TotalPetUpgrade, 1)
	
	EventManager:Dispatch(EventManager.Define.QuestPetUpgrade, {
		Player = player,
		Param = targetLevel,
		Value = 1,
	})
	
	return result
end

return Pet
