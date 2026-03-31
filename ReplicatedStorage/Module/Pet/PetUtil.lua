local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local AttributeUtil = require(game.ReplicatedStorage.ScriptAlias.AttributeUtil)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)

local Define =require(game.ReplicatedStorage.Define)

local PetUtil = {}

local MaxPower = 0

function PetUtil:CheckPackage(count)
	local result = NetClient:RequestWait("Pet", "CheckPackage", { Value = count })
	if result then
		return true
	else
		UIManager:ShowMessage(Define.Message.PackageFull)
		return false
	end
end

function PetUtil:ProcessPetInfo(info)
	local data = ConfigManager:GetData("Pet", info.ID)
	local upgradeData = ConfigManager:SearchData("PetUpgrade", "PetID", info.ID, "Level", info.UpgradeLevel)
	info.Icon = data.Icon
	info.Rarity = data.Rarity

	local getCoinFactor = 0
	if data.MaxExistCoinFactor > 0 then
		getCoinFactor = data.MaxExistCoinFactor * info.UpgradeFactor * MaxPower
		local displayValue = (data.MaxExistCoinFactor * info.UpgradeFactor) * 100
		info.DisplayGetCoinFactor = ""..string.format("%.0f", displayValue).."%"
	else
		getCoinFactor = data.GetCoinFactor1 * info.UpgradeFactor
		info.DisplayGetCoinFactor = ""..string.format("%.2f", getCoinFactor).."X"
	end
	
	info.GetCoinFactor1 = getCoinFactor
	info.IsSelect = false

	return info
end

function PetUtil:GetSorttedPackageList(callback)
	NetClient:RequestQueue({
		{ Module = "Pet", Action = "GetPackageList" },
		{ Module = "Pet", Action = "GetMaxCoinFactor" },
	}, function(result)
		local infoList = result[1]
		MaxPower = result[2]
		if not infoList then
			infoList = {}
		end
		
		for _, info in ipairs(infoList) do
			PetUtil:ProcessPetInfo(info)
		end

		-- 按稀有度，速度降序排序
		infoList = PetUtil:Sort(infoList)
		callback(infoList)
	end)
end

function PetUtil:Sort(infoList)
	infoList = Util:ListSort(infoList, {
		--function(info) return info.IsEquip and -1 or 1 end,
		function(info) return -info.GetCoinFactor1 end,
		function(info) return -info.Rarity end,
		function(info) return -info.ID end,
	})
	
	return infoList
end

function PetUtil:GetEquipList()
	local result = nil
	local infoList = NetClient:RequestWait("Pet", "GetEquipList")
	for _, info in pairs(infoList) do
		PetUtil:ProcessPetInfo(info)
	end

	result = infoList
	return result
end

function PetUtil:GetUpgradableList(petInstanceID, callback)
	PetUtil:GetSorttedPackageList(function(infoList)
		for _, info in pairs(infoList) do
			PetUtil:ProcessPetInfo(info)
		end

		local petInfo = Util:ListFind(infoList, function(info)
			return info.InstanceID == petInstanceID
		end)
		infoList = Util:ListFindAll(infoList, function(info)
			local c1 = not info.IsLock
			local c2 = not info.IsEquip
			local c3 = info.UpgradeLevel < 3
			local c4 = petInfo == nil or (petInfo.ID == info.ID and petInfo.UpgradeLevel == info.UpgradeLevel)
			return c1 and c2 and c3 and c4
		end)
		
		callback(infoList)
	end)
end

function PetUtil:OpenLoot(lootKey, deleteIDList, count, callback)
	NetClient:Request("PetLoot", "Open", {
		LootKey = lootKey,
		Count = count,
		DeleteIDList = deleteIDList
	}, function(result)
		local success = result.Success
		if success then
			callback(result)
		else
			callback(result)
			UIManager:ShowMessage(result.Message)
		end
	end)
end

return PetUtil
