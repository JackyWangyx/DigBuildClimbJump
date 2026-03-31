local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local AttributeUtil = require(game.ReplicatedStorage.ScriptAlias.AttributeUtil)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)

local Define =require(game.ReplicatedStorage.Define)

local AnimalUtil = {}

function AnimalUtil:GetStoreList()
	local dataList = ConfigManager:SearchAllData("Animal", "ShowInShop", true)
	dataList = Util:ListSort(dataList, {
		--function(info) return info.IsEquip and -1 or 1 end,
		function(info) return info.CostCoin end,
		function(info) return info.CostWins end,
		function(info) return info.CostRobux end,
	})
	
	--AnimalUtil:MoveAfterCondition(dataList, function(info)
	--	return info.ID == 1
	--end, function(info)
	--	return info.CostRobux > 0
	--end)
	
	return dataList
end

function AnimalUtil:CheckPackage(count)
	local result = NetClient:RequestWait("Animal", "CheckPackage", { Value = count })
	if result then
		return true
	else
		UIManager:ShowMessage(Define.Message.AnimalPackageFull)
		return false
	end
end

function AnimalUtil:ProcessAnimalInfo(info)
	local data = ConfigManager:GetData("Animal", info.ID)
	local upgradeFactor = 1
	Util:TableMerge(info, data)
	info.IsSelect = false
	return info
end

function AnimalUtil:GetSorttedPackageList(callback)
	NetClient:Request("Animal", "GetPackageList", function(infoList)
		for _, info in ipairs(infoList) do
			AnimalUtil:ProcessAnimalInfo(info)
		end

		-- 按稀有度，速度降序排序
		--infoList = AnimalUtil:Sort(infoList)
		callback(infoList)
	end)
end

function AnimalUtil:Sort(infoList)
	-- 优先RB付费，价格升序
	infoList = Util:ListSort(infoList, {
		--function(info) return info.IsEquip and -1 or 1 end,
		function(info) return info.CostCoin end,
		function(info) return info.CostWins end,
		function(info) return info.CostRobux end,
	})

	return infoList
end

function AnimalUtil:SortDesc(infoList)
	-- 优先RB付费，价格升序
	infoList = Util:ListSort(infoList, {
		--function(info) return info.IsEquip and -1 or 1 end,
		function(info) return -info.CostRobux end,
		function(info) return info.CostWins end,
		function(info) return -info.CostCoin end,
	})

	return infoList
end

function AnimalUtil:MoveAfterCondition(data, conditionA, conditionB)
	local indexA, lastIndexB, elementA
	for i, v in ipairs(data) do
		if not indexA and conditionA(v) then
			indexA = i
			elementA = v
		end
		if conditionB(v) then
			lastIndexB = i
		end
	end

	if not indexA or not lastIndexB then
		return
	end

	table.remove(data, indexA)
	if indexA < lastIndexB then
		lastIndexB = lastIndexB - 1
	end

	table.insert(data, lastIndexB + 1, elementA)
end

function AnimalUtil:GetEquipList()
	local result = nil
	local infoList = NetClient:RequestWait("Animal", "GetEquipList")
	for _, info in ipairs(infoList) do
		AnimalUtil:ProcessAnimalInfo(info)
	end

	result = infoList
	return result
end

return AnimalUtil
