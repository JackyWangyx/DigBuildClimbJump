local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local PlayerProperty = require(game.ServerScriptService.ScriptAlias.PlayerProperty)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)
local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)

local Define = require(game.ReplicatedStorage.Define)

local PetLoot = {}

function PetLoot:Init ()

end

function PetLoot:GetLootList(player, param)
	local lootKey = param.LootKey
	if not lootKey then return {} end
	local dataList = Util:TableCopy(ConfigManager:GetDataList(lootKey))
	
	local luckKeyDic = {
		[1] = PlayerProperty.Define.LUCKY_GET_PET_COMMON,
		[2] = PlayerProperty.Define.LUCKY_GET_PET_RARE,
		[3] = PlayerProperty.Define.LUCKY_GET_PET_EPIC,
		[4] = PlayerProperty.Define.LUCKY_GET_PET_LEGENDARY,
		[5] = PlayerProperty.Define.LUCKY_GET_PET_SECRET,
		[6] = PlayerProperty.Define.LUCKY_GET_PET_MYTHICAL,
	}
	
	-- 计算加成概率
	local playerGameProperty = PlayerProperty:GetGameProperty(player)
	local result = {}
	for _, data in pairs(dataList) do
		local weight = data.Weight
		local petData = ConfigManager:GetData("Pet", data.PetID)
		local maxWeightData = Util:ListMax(dataList, function(item) return item.Weight end)

		local luckyKey = luckKeyDic[petData.Rarity]
		local luckyValue = playerGameProperty[luckyKey]
		local weightDiffValue = weight * luckyValue
		data.Weight = data.Weight + weightDiffValue
		maxWeightData.Weight = maxWeightData.Weight - weightDiffValue
		table.insert(result, data)
	end
	
	return result
end

function PetLoot:Open(player, param)
	local lootKey = param.LootKey
	local count = param.Count
	local deleteIDList = param.DeleteIDList or {}
	local lootDataList = PetLoot:GetLootList(player, param)

	
	-- 检查余额
	local costCoin = lootDataList[1].CostCoin * count
	if costCoin > 0 then
		local coinRemain = NetServer:RequireModule("Account"):GetCoin(player)
		if coinRemain < costCoin  then
			return {
				Success = false, 
				Message = Define.Message.CoinNotEnough,
				PetList = nil
			}
		end
	end
	
	local costWins = lootDataList[1].CostWins * count
	if costWins > 0 then
		local winsRemain = NetServer:RequireModule("Account"):GetWins(player)
		if winsRemain < costWins  then
			return {
				Success = false, 
				Message = Define.Message.WinsNotEnough,
				PetList = nil
			}
		end
	end

	-- 检查背包
	local packageCount = NetServer:RequireModule("Pet"):GetPackageCount(player)
	local packageMax = NetServer:RequireModule("Pet"):GetPackageMax(player)
	if packageCount + count > packageMax then
		return {
			Success = false, 
			Message = Define.Message.PackageFull,
			PetList = nil
		}
	end
	
	-- 付费
	NetServer:RequireModule("Account"):SpendCoin(player, { Value = costCoin} )
	NetServer:RequireModule("Account"):SpendWins(player, { Value = costWins} )
	
	local result = {
		Success = true, 
		PetList = {}
	}
	
	for i = 1, count do
		local randLootData = Util:ListRandomWeight(lootDataList)
		local petID = randLootData.PetID

		-- 随机突破
		local upgradeLevel = 1
		local luckyPetUprgrade = PlayerProperty:GetGamePropertyValue(player, PlayerProperty.Define.LUCKY_PET_UPGRADE)
		local randValue = math.random()
		if randValue <= luckyPetUprgrade then
			upgradeLevel = 2
		end
		
		-- 自动删除
		local requireDelete = Util:ListContains(deleteIDList, petID)
		if not requireDelete then
			local addPetResult = NetServer:RequireModule("Pet"):Add(player, { ID = petID, UpgradeLevel = upgradeLevel })
			if addPetResult then
				PlayerRecord:AddValue(player, PlayerRecord.Define.TotalPetLoot, 1)
				EventManager:Dispatch(EventManager.Define.QuestPetLoot, {
					Player = player,
					Value = 1,
				})
			end
		end
		
		local petData = ConfigManager:GetData("Pet", petID)
		local info = Util:TableCopy(petData)
		info.UpgradeLevel = upgradeLevel
		table.insert(result.PetList, info)
	end
	
	AnalyticsManager:Event(player, AnalyticsManager.Define.PetLoot, "PetLootKey", lootKey)
	PlayerRecord:AddValue(player, PlayerRecord.Define.TotalPetLoot, 1)
	EventManager:Dispatch(EventManager.Define.QuestPetLoot, {
		Player = player,
		Param = lootKey,
		Value = 1,
	})
	
	return result
end

return PetLoot
