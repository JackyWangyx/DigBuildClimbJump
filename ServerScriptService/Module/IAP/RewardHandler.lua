local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local PlayerProperty = require(game.ServerScriptService.ScriptAlias.PlayerProperty)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local Define = require(game.ReplicatedStorage.Define)

local RewardHandler = {}

------------------------------------------------------------------------------------
-- Internal Impl

function RewardHandler:GetRewardRequest(player, rewardData)
	if not rewardData then
		return {
			Success = false,
			Message = Define.Message.RedeemNotExist,
		}
	end

	local rewardType = rewardData.RewardType
	local rewardID = rewardData.RewardID
	local rewardCount = rewardData.RewardCount
	RewardHandler:GetReward(player, rewardType, rewardID, rewardCount)
	local rewardList = {}
	if rewardType == "Package" then
		rewardList = ConfigManager:SearchAllData("RewardPackage", "PackageID", rewardID)
	else
		table.insert(rewardList, rewardData)
	end

	return {
		Success = true,
		Message = "Success",
		RewardList = rewardList
	}
end

------------------------------------------------------------------------------------
-- Reward

function RewardHandler:GetRewardList(player, rewardList)
	for _, data in ipairs(rewardList) do
		local rewardType = data.RewardType
		local rewardID = data.RewardID
		local rewardCount = data.RewardCount
		RewardHandler:GetReward(player, rewardType, rewardID, rewardCount)
	end
	
	return true
end

function RewardHandler:GetReward(player, rewardType, rewardID, rewardCount)
	local getFunction = RewardHandler["Get".. rewardType]
	if getFunction then
		local success, message = pcall(function()
			local result = getFunction(self, player, rewardID, rewardCount)
			return result
		end)
		
		if success then
			local result = message
			return result
		else
			warn("[Reward] Get fail : ", player, rewardType, rewardID, rewardCount, message)
		end
	else
		warn("[Reward] Get func not found : ", player, rewardType, rewardID, rewardCount)
		return false
	end
end

----------------------------------------------------------------------------------------
-- Impl

-- Package

function RewardHandler:GetPackage(player, rewardID, rewardCount)
	local rewardList = ConfigManager:SearchAllData("RewardPackage", "PackageID", rewardID)
	local result = RewardHandler:GetRewardList(player, rewardList)
	return result
end

-- Account

function RewardHandler:GetCoin(player, rewardID, rewardCount)
	local request = require(game.ServerScriptService.ScriptAlias.Account)
	local getCoinFactor = PlayerProperty:GetGamePropertyValue(player, PlayerProperty.Define.GET_COIN_FACTOR)
	local value = math.round(rewardCount * getCoinFactor)
	request:AddCoin(player, { Value = value })
	return true
end

function RewardHandler:GetWins(player, rewardID, rewardCount)
	local request = require(game.ServerScriptService.ScriptAlias.Account)
	local getWinsFactor = PlayerProperty:GetGamePropertyValue(player, PlayerProperty.Define.GET_WINS_FACTOR)
	local value = math.round(rewardCount * getWinsFactor)
	request:AddWins(player, { Value = value })
	return true
end

function RewardHandler:GetPower(player,rewardID, rewardCount)
	local request =require(game.ServerScriptService.ScriptAlias.Training)
	local getPowerFactor = PlayerProperty:GetGamePropertyValue(player, PlayerProperty.Define.GET_POWER_FACTOR)
	local value = math.round(rewardCount * getPowerFactor)
	request:AddPower(player, { Value = value })
	return true
end

function RewardHandler:GetPassPoint(player, rewardID, rewardCount)
	local request = require(game.ServerScriptService.ScriptAlias.Quest)
	request:AddPassPoint(player, { Value = rewardCount })
	return true
end

-- Pet / Animal / Partner / Trail / Tool / Equipment / Prop

function RewardHandler:GetPet(player, rewardID, rewardCount)
	local request = require(game.ServerScriptService.ScriptAlias.Pet)
	for i = 1, rewardCount do
		request:Add(player, { ID = rewardID })
	end
	
	request:EquipBest(player)
	
	return true
end

function RewardHandler:GetAnimal(player, rewardID, rewardCount)
	local request = require(game.ServerScriptService.ScriptAlias.Animal)
	for i = 1, rewardCount do
		request:Add(player, { ID = rewardID })
	end
	
	return true
end

function RewardHandler:GetPartner(player, rewardID, rewardCount)
	local request = require(game.ServerScriptService.ScriptAlias.Partner)
	request:Get(player, { ID = rewardID })
	return true
end

function RewardHandler:GetTrail(player, rewardID, rewardCount)
	local request = require(game.ServerScriptService.ScriptAlias.Trail)
	request:Get(player, { ID = rewardID })
	return true
end

function RewardHandler:GetTool(player, rewardID, rewardCount)
	local request = require(game.ServerScriptService.ScriptAlias.Tool)
	request:Get(player, { ID = rewardID })
	return true
end

function RewardHandler:GetEquipment(player, rewardID, rewardCount)
	local request = require(game.ServerScriptService.ScriptAlias.Equipment)
	request:Get(player, { ID = rewardID })
	return true
end

function RewardHandler:GetProp(player, rewardID, rewardCount)
	local request = require(game.ServerScriptService.ScriptAlias.Prop)
	request:Buy(player, { ID = rewardID, Count = rewardCount })
	return true
end

-- Pet Loot

function RewardHandler:GetPetLoot(player, rewardID, rewardCount)
	local petLootKey = rewardID
	local lootCount = rewardCount
	local times = 1
	if lootCount == 9 then
		lootCount = 3
		times = 3
	end

	local lootData = ConfigManager:SearchData("PetLoot", "LootKey", petLootKey)
	local param = {}
	param.LootKey = petLootKey
	param.EggPrefab = lootData.EggPrefab
	param.LootCount = lootCount
	param.OpenAuto = true
	param.IsRobuxLoot = lootData.IsRobuxLoot
	param.DeleteIDList = {}
	param.IsRewardLoot = true
	param.Times = times

	EventManager:DispatchToClient(player, "OpenPetLoot", param)
	return true
end

-- LuckyWheel

function RewardHandler:GetLuckyWheel(player, rewardID, rewardCount)
	local request = require(game.ServerScriptService.ScriptAlias.LuckyWheel)
	request:Buy(player, { Value = rewardCount })
	return true
end

-- Pacakge / Equip

function RewardHandler:GetPetPackage(player, rewardID, rewardCount)
	local request = require(game.ServerScriptService.ScriptAlias.Pet)
	request:AddPackageAdditional(player, { Value = rewardCount })
	return true
end

function RewardHandler:GetPetEquip(player, rewardID, rewardCount)
	local request = require(game.ServerScriptService.ScriptAlias.Pet)
	request:AddEquipAdditional(player, { Value = rewardCount })
	return true
end

function RewardHandler:GetAniamlPackage(player, rewardID, rewardCount)
	local request = require(game.ServerScriptService.ScriptAlias.Animal)
	request:AddPackageAdditional(player, { Value = rewardCount })
	return true
end

function RewardHandler:GetAniamlEquip(player, rewardID, rewardCount)
	local request = require(game.ServerScriptService.ScriptAlias.Animal)
	request:AddEquipAdditional(player, { Value = rewardCount })
	return true
end

-- Porperty

function RewardHandler:GetProperty1(player, rewardID, rewardCount)
	local request = require(game.ServerScriptService.ScriptAlias.PlayerProperty)
	local propertyPrefix = 1
	local propertyKey = rewardID
	local propertyValue = rewardCount
	request:AddPlayerProperty(player, propertyPrefix, propertyKey, propertyValue)
	return true
end

function RewardHandler:GetProperty2(player, rewardID, rewardCount)
	local request = require(game.ServerScriptService.ScriptAlias.PlayerProperty)
	local propertyPrefix = 2
	local propertyKey = rewardID
	local propertyValue = rewardCount
	request:AddPlayerProperty(player, propertyPrefix, propertyKey, propertyValue)
	return true
end

function RewardHandler:GetProperty3(player, rewardID, rewardCount)
	local request = require(game.ServerScriptService.ScriptAlias.PlayerProperty)
	local propertyPrefix = 3
	local propertyKey = rewardID
	local propertyValue = rewardCount
	request:AddPlayerProperty(player, propertyPrefix, propertyKey, propertyValue)
	return true
end

return RewardHandler
