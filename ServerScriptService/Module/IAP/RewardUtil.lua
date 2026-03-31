local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local RewardUtil = {}

function RewardUtil:GetRewardList(player, rewardList)
	for _, data in ipairs(rewardList) do
		local rewardType = data.RewardType
		local rewardID = data.RewardID
		local rewardCount = data.RewardCount
		RewardUtil:GetReward(player, rewardType, rewardID, rewardCount)
	end
	
	return true
end

function RewardUtil:GetReward(player, rewardType, rewardID, rewardCount)
	--print(player.UserId, rewardType, rewardID, rewardCount)
	
	if rewardType == "Package" then
		local rewardList = ConfigManager:SearchAllData("RewardPackage", "PackageID", rewardID)
		local result = RewardUtil:GetRewardList(player, rewardList)
		return result
	end
	
	if rewardType == "Pet" then
		for i = 1, rewardCount do
			local request = require(game.ServerScriptService.ScriptAlias.Pet)
			request:Add(player, { ID = rewardID })
		end
		return true
	end
	
	if rewardType == "Animal" then
		for i = 1, rewardCount do
			local request = require(game.ServerScriptService.ScriptAlias.Animal)
			request:Add(player, { ID = rewardID })
		end
		return true
	end
	
	if rewardType == "PetPackage" then
		local request = require(game.ServerScriptService.ScriptAlias.Pet)
		request:AddPackageAdditional(player, { Value = rewardCount })
		return true
	end
	
	if rewardType == "PetEquip" then
		local request = require(game.ServerScriptService.ScriptAlias.Pet)
		request:AddEquipAdditional(player, { Value = rewardCount })
		return true
	end
	
	if rewardType == "AnimalPackage" then
		local request = require(game.ServerScriptService.ScriptAlias.Animal)
		request:AddPackageAdditional(player, { Value = rewardCount })
		return true
	end

	if rewardType == "AnimalEquip" then
		local request = require(game.ServerScriptService.ScriptAlias.Animal)
		request:AddEquipAdditional(player, { Value = rewardCount })
		return true
	end

	if rewardType == "Tool" then
		local request = require(game.ServerScriptService.ScriptAlias.Tool)
		request:Get(player, { ID = rewardID })
		return true
	end

	if rewardType == "Trail" then
		local request = require(game.ServerScriptService.ScriptAlias.Trail)
		request:Get(player, { ID = rewardID })
		return true
	end
	
	if rewardType == "Partner" then
		local request = require(game.ServerScriptService.ScriptAlias.Partner)
		request:Get(player, { ID = rewardID })
		return true
	end
	
	if rewardType == "Prop" then
		local request = require(game.ServerScriptService.ScriptAlias.Prop)
		request:Buy(player, { ID = rewardID, Count = rewardCount })
		return true
	end

	if rewardType == "Coin" then
		local request = require(game.ServerScriptService.ScriptAlias.Account)
		request:AddCoin(player, { Value = rewardCount })
		return true
	end
	
	if rewardType == "Wins" then
		local request = require(game.ServerScriptService.ScriptAlias.Account)
		request:AddWins(player, { Value = rewardCount })
		return true
	end

	if rewardType == "Power" then
		local request =require(game.ServerScriptService.ScriptAlias.Training)
		request:AddPower(player, { Value = rewardCount })
		return true
	end
	
	if rewardType == "PassPoint" then
		local request = require(game.ServerScriptService.ScriptAlias.Quest)
		request:AddPassPoint(player, { Value = rewardCount })
		return true
	end
	
	if rewardType == "LuckyWheel" then
		local request = require(game.ServerScriptService.ScriptAlias.LuckyWheel)
		request:Buy(player, { Value = rewardCount })
		return true
	end
	
	if rewardType == "PetLoot" then
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
	
	if rewardType == "Property1" then
		local request = require(game.ServerScriptService.ScriptAlias.PlayerProperty)
		local propertyPrefix = 1
		local propertyKey = rewardID
		local propertyValue = rewardCount
		request:AddPlayerProperty(player, propertyPrefix, propertyKey, propertyValue)
		return true
	end
	
	if rewardType == "Property2" then
		local request = require(game.ServerScriptService.ScriptAlias.PlayerProperty)
		local propertyPrefix = 2
		local propertyKey = rewardID
		local propertyValue = rewardCount
		request:AddPlayerProperty(player, propertyPrefix, propertyKey, propertyValue)
		return true
	end
	
	if rewardType == "Property3" then
		local request = require(game.ServerScriptService.ScriptAlias.PlayerProperty)
		local propertyPrefix = 3
		local propertyKey = rewardID
		local propertyValue = rewardCount
		request:AddPlayerProperty(player, propertyPrefix, propertyKey, propertyValue)
		return true
	end
	
	return true
end

return RewardUtil
