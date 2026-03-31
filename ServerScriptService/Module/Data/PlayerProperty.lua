local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local PlayerCache = require(game.ServerScriptService.ScriptAlias.PlayerCache)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)
local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)

local Define = require(game.ReplicatedStorage.Define)

local PlayerProperty = {}

PlayerProperty.DATA_MODULE_KEY = "PlayerProperty"
PlayerProperty.Define = require(game.ReplicatedStorage.Define).PlayerProperty

-- 玩家默认属性
local DefaultPlayerSaveProperty = {
	-- 数值
	Speed = 14,
	Acceleration = 10,		-- 基础 加速度
	MaxSpeedFactor = 1,		-- 最大速度加成倍率，作用于 由 Power 计算得出 MaxSpeed
	
	BasePower = 100,		-- 基础 Power
	PowerLimit = 0,			-- Power 限制

	-- 百分比
	GetPowerFactor = 1,		-- 获取速度倍率系数 1 = 100% 1 倍
	GetCoinFactor = 1,		-- 获取金币倍率系数
	GetWinsFactor = 1,		-- 获取奖杯倍率系数

	-- 百分比
	LuckyGetPetCommon = 0,		-- 抽奖1稀有度 加成概率
	LuckyGetPetRare = 0,		-- 抽奖2稀有度 加成概率				
	LuckyGetPetEpic = 0,		-- 抽奖3稀有度 加成概率
	LuckyGetPetLegendary = 0,	-- 抽奖4稀有度 加成概率
	LuckyGetPetSecret = 0,		-- 抽奖5稀有度 加成概率
	LuckyGetPetMythical = 0,	-- 抽奖6稀有度 加成概率

	-- 百分比
	LuckyPetUpgrade = 0,	-- 抽奖直接突破 加成概率
}

-- 生效数值 = [(玩家基础数值 + 基础数值加成) x (1 + 基础数值倍率加成)] x (1 + 最终数值倍率加成)
-- FinalValue = [(PlayerValue + BaseValue) x (1 + BaseFactor)] x (1 + FinalFactor)


-- 通用空属性表
-- 配置表中 属性名1 属性名2 属性名3 对应同一个属性的三个加成值
local EmptyProperty = {
	Speed = 0,
	Acceleration = 0,
	
	MaxSpeedFactor = 0,
	BasePower = 0,
	PowerLimit = 0,

	GetPowerFactor = 0,
	GetCoinFactor = 0,
	GetWinsFactor = 0,
	
	LuckyGetPetCommon = 0,
	LuckyGetPetRare = 0,
	LuckyGetPetEpic = 0,
	LuckyGetPetLegendary = 0,
	LuckyGetPetSecret = 0,
	LuckyGetPetMythical = 0,
	
	LuckyPetUpgrade = 0,
}

-- 1倍概率表
local OneProperty = {
	Speed = 1,
	Acceleration = 1,
	MaxSpeedFactor = 1,
	
	BasePower = 1,
	PowerLimit = 1,
	
	GetPowerFactor = 1,
	GetCoinFactor = 1,
	GetWinsFactor = 1,
	
	LuckyGetPetCommon = 1,
	LuckyGetPetRare = 1,
	LuckyGetPetEpic = 1,
	LuckyGetPetLegendary = 1,
	LuckyGetPetSecret = 1,
	LuckyGetPetMythical = 1,
	
	LuckyPetUpgrade = 1,
}

PlayerProperty.PropertyKeyList = {
	PlayerProperty.Define.SPEED,
	PlayerProperty.Define.ACCELERATION,
	PlayerProperty.Define.MAX_SPEED_FACTOR,
	
	PlayerProperty.Define.BASE_POWER,
	PlayerProperty.Define.POWER_LIMIT,

	PlayerProperty.Define.GET_POWER_FACTOR,
	PlayerProperty.Define.GET_COIN_FACTOR,
	PlayerProperty.Define.GET_WINS_FACTOR,
	
	PlayerProperty.Define.LUCKY_GET_PET_COMMON,
	PlayerProperty.Define.LUCKY_GET_PET_RARE,
	PlayerProperty.Define.LUCKY_GET_PET_EPIC,
	PlayerProperty.Define.LUCKY_GET_PET_LEGENDARY,
	PlayerProperty.Define.LUCKY_GET_PET_SECRET,
	PlayerProperty.Define.LUCKY_GET_PET_MYTHICAL,
	PlayerProperty.Define.LUCKY_PET_UPGRADE,
}

local PlayerGamePropertyCache = {} 

function PlayerProperty:Init()
	PlayerManager:HandlePlayerAddRemove(function(player)
		
	end, function(player)
		PlayerProperty:ClearCache(player)
	end)
	
	EventManager:Listen(EventManager.Define.RefreshPlayerProperty, function(player)
		PlayerProperty:ClearCache(player)
	end)
end

function PlayerProperty:ClearCache(player)
	PlayerGamePropertyCache[player] = nil
end

-- 获取最终游戏属性
function PlayerProperty:GetGameProperty(player)
	if not player or not player.Parent then
		return DefaultPlayerSaveProperty
	end
	
	local resultProperty = PlayerGamePropertyCache[player]
	if resultProperty then
		return resultProperty
	end
	
	resultProperty = Util:TableCopy(EmptyProperty)
	local allPropertys = PlayerProperty:CollectAllProperties(player)
	
	-- 存档基础数值
	local saveBaseProperty = PlayerProperty:GetPlayerProperty(player, 1)
	PlayerProperty:PropertyCombineAdd(resultProperty, saveBaseProperty)
	PlayerProperty:PropertyCombineAdd(resultProperty, allPropertys["1"])
	
	-- 基础倍率
	local baseFactorProperty = Util:TableCopy(OneProperty)
	PlayerProperty:PropertyCombineAdd(baseFactorProperty, allPropertys["2"])
	local saveBaseFactorProperty = PlayerProperty:GetPlayerProperty(player, 2)
	PlayerProperty:PropertyCombineAdd(baseFactorProperty, saveBaseFactorProperty)
	PlayerProperty:PropertyCombineMultiple(resultProperty, baseFactorProperty)
	
	-- 最终倍率
	local finalFactorProperty = Util:TableCopy(OneProperty)
	PlayerProperty:PropertyCombineAdd(finalFactorProperty, allPropertys["3"])
	local saveFinalFactorProperty = PlayerProperty:GetPlayerProperty(player, 3)
	PlayerProperty:PropertyCombineAdd(finalFactorProperty, saveFinalFactorProperty)
	PlayerProperty:PropertyCombineMultiple(resultProperty, finalFactorProperty)
	
	PlayerGamePropertyCache[player] = resultProperty
	return resultProperty
end

function PlayerProperty:CollectAllProperties(player)
	local allPropertys = {}
	local suffixList = {"1", "2", "3"}
	for _, suffix in ipairs(suffixList) do
		allPropertys[suffix] = {}
	end

	local function collect(propSourceName, data)
		for _, suffix in ipairs(suffixList) do
			local prop = PlayerProperty:SelectProperty(data, suffix)
			PlayerProperty:PropertyCombineAdd(allPropertys[suffix], prop)
		end
		PlayerProperty:Log(propSourceName, data)
	end

	-- 🐰Pet
	local petRequest = NetServer:RequireModule("Pet")
	do
		local petProperty = {}
		local maxPower = petRequest:GetMaxCoinFactor(player)
		petProperty["GetCoinFactor1"] = 0
		for _, petInfo in ipairs(petRequest:GetEquipList(player)) do
			local petData = ConfigManager:GetData("Pet", petInfo.ID)
			local power = 0
			if petData.MaxExistCoinFactor > 0 then
				power = petData.MaxExistCoinFactor * maxPower * petInfo.UpgradeFactor
			else
				power = petData.GetCoinFactor1 * petInfo.UpgradeFactor
			end
			
			petProperty["GetCoinFactor1"] += power
		end
		collect("🐰Pet", petProperty)
	end
	
	-- 🐶Animal
	--local animalRequest = NetServer:RequireModule("Animal")
	--do
	--	local animalProperty = {}
	--	for _, animalInfo in ipairs(animalRequest:GetEquipList(player)) do
	--		local animalData = ConfigManager:GetData("Animal", animalInfo.ID)
	--		collect("🐶Animal", animalData)
	--	end
	--end

	-- 🛠️Tool
	local toolRequest = NetServer:RequireModule("Tool")
	local toolInfo = toolRequest:GetEquip(player)
	--if toolInfo then collect("🛠️Tool", ConfigManager:GetData("🛠️Tool", toolInfo.ID)) end
	
	-- Start : Max PowerCapacity
	local maxPowerCapacity = toolRequest:GetMaxPowerCapacity(player)
	local toolData = ConfigManager:GetData("Tool", toolInfo.ID)
	local toolProperty = {}
	local powerCapacity = 0
	if toolData.MaxExistPowerCapacityFactor and toolData.MaxExistPowerCapacityFactor > 0 then
		powerCapacity = toolData.MaxExistPowerCapacityFactor * maxPowerCapacity
	else
		powerCapacity = toolData.PowerCapacity
	end
	toolProperty["PowerCapacity"] = powerCapacity
	if toolInfo then collect("🛠️Tool", toolProperty) end
	-- End : Max PowerCapacity
	
	-- 🛠️Equipment
	local equipmentRequest = NetServer:RequireModule("Equipment")
	local equipmentInfo = equipmentRequest:GetEquip(player)
	if equipmentInfo then collect("🛠️Equipment", ConfigManager:GetData("Equipment", equipmentInfo.ID)) end

	-- 💫Trail
	local trailRequest = NetServer:RequireModule("Trail")
	local trailInfo = trailRequest:GetEquip(player)
	if trailInfo then collect("💫Trail", ConfigManager:GetData("Trail", trailInfo.ID)) end
	
	-- 🧑Partner
	local partnerRequest = NetServer:RequireModule("Partner")
	local partnerInfo = partnerRequest:GetEquip(player)
	if partnerInfo then collect("🧑Partner", ConfigManager:GetData("Partner", partnerInfo.ID)) end
	
	-- ♻️Rebirth
	local rebirthRequest = NetServer:RequireModule("Rebirth")
	local rebirthData = rebirthRequest:GetInfo(player)
	if rebirthData then collect("♻️Rebirth", rebirthData) end

	-- 💊Prop
	local propRequest = NetServer:RequireModule("Prop")
	for _, propData in ipairs(propRequest:GetRuntimePropertyList(player)) do
		collect("💊Prop : " .. propData.Name, propData)
	end

	-- 🟢Buff Online
	local buffOnline = require(game.ServerScriptService.ScriptAlias.BuffOnlineHandler)
	local buffOnlineProperty = buffOnline:GetProperty(player)
	if buffOnlineProperty then collect("🟢Buff Online", buffOnlineProperty) end

	-- 💖Buff Friend Online
	local friendOnline = NetServer:RequireModule("Friend")
	local friendProperty = friendOnline:GetProperty(player)
	if friendProperty then collect("💖Buff Friend Online", friendProperty) end
	
	-- ✨Buff Premium
	local premium = NetServer:RequireModule("RobloxPremium")
	local premiumProperty = premium:GetProperty(player)
	if premiumProperty then collect("✨Buff Premium", premiumProperty) end

	-- 💎Game Pass
	local iapProperty = require(game.ServerScriptService.ScriptAlias.IAPProperty)
	for _, iap in pairs(iapProperty:GetPropertyList(player)) do
		collect("💎Game Pass : " .. iap.ProductKey, iap)
	end
	
	-- 💎Season Pass
	local quest = require(game.ServerScriptService.ScriptAlias.Quest)
	local hasPass = quest:CheckSeasonPass(player)
	if hasPass then
		collect("💎Season Pass", Define.Quest.SeasonPassProperty)
	end

	return allPropertys
end

function PlayerProperty:Log(type, property)
	if not Define.Test.EnablePropertyLog then return end
	print("[Property] "..type, property)
end

function PlayerProperty:GetPropertyFromData(data, key)
	local value = data[key];
	if value == nil then return 0 end
	return value
end

-- 获取游戏最终生效属性
function PlayerProperty:GetGamePropertyValue(player, key)
	local success, msg = pcall(function()
		local gameProperty = PlayerProperty:GetGameProperty(player)
		if not gameProperty then
			return DefaultPlayerSaveProperty[key]
		end
		local result = gameProperty[key]
		if not result then result = 0 end
		return result
	end)
	
	if success then
		return msg
	else
		warn("Get Game Property Failed! : ", key, debug.traceback(msg, 2))
		return DefaultPlayerSaveProperty[key]
	end
end

-- 获取玩家基础属性
function PlayerProperty:GetPlayerPropertyValue(player, key)
	local success, msg = pcall(function()
		local playerProperty = PlayerProperty:GetPlayerProperty(player)
		local result = playerProperty[key]
		if not result then result = 0 end
		return result
	end)
	
	if success then
		return msg
	else
		warn("Get Player Property Failed! : ", key, debug.traceback(msg, 2))
		return DefaultPlayerSaveProperty[key]
	end
end

-- 设置玩家基础属性 更新存档
function PlayerProperty:SetPlayerPropertyValue(player, key, value)
	local playerProperty = PlayerProperty:GetPlayerProperty(player)
	playerProperty[key] = value
	PlayerProperty:ClearCache(player)
end

-- 增加玩家永久属性
function PlayerProperty:AddPlayerProperty(player, prefix, key, value)
	local propertyCollection = PlayerProperty:GetPlayerProperty(player, prefix)
	local propertyValue = propertyCollection[key]
	if propertyValue == nil then
		propertyValue = 0
	end
	
	propertyValue += value
	propertyCollection[key] = propertyValue
	PlayerProperty:ClearCache(player)
end

-- 获取实际最大速度
function PlayerProperty:GetMaxSpeedByPower(player, power)
	if not power then
		power = 0
	end
	local result = power
	if power >= 100 and power <= 1000 then
		result = 0.25 * power + 30
	end
	
	if power >= 1001 and power <= 100000 then
		result = 0.015 * power + 300
	end
	
	if power >= 100001 and power <= 10000000 then
		result = 0.0002 * power + 1800
	end
	
	if power >= 10000001 and power <= 1000000000 then
		result = 3e-6 * power + 3900
	end
	
	if power >= 1000000001 and power <= 100000000000 then
		result = 6e-8 * power + 6880
	end
	
	if power >= 100000000001 then
		result = 3e-9 * power + 12800
	end
	
	return result 
end

-- 获取玩家全部基础属性
function PlayerProperty:GetPlayerProperty(player, prefix)
	local saveInfo = PlayerPrefs:GetModule(player, PlayerProperty.DATA_MODULE_KEY)
	if prefix == nil or prefix == 1 then
		local baseProperty = saveInfo.BaseProperty
		if Util:IsListEmpty(baseProperty) then
			baseProperty = Util:TableCopy(DefaultPlayerSaveProperty)
			saveInfo.BaseProperty = baseProperty
		end
		
		return baseProperty
	elseif prefix == 2 then
		local baseFactor = saveInfo.BaseFactor
		if Util:IsListEmpty(baseFactor) then
			baseFactor = Util:TableCopy(EmptyProperty)
			saveInfo.BaseFactor = baseFactor
		end

		return baseFactor
	elseif prefix == 3 then
		local finalFactor = saveInfo.FinalFactor
		if Util:IsListEmpty(finalFactor) then
			finalFactor = Util:TableCopy(EmptyProperty)
			saveInfo.FinalFactor = finalFactor
		end

		return finalFactor
	end
	
	return nil
end

-- 筛选指定后缀的属性
function PlayerProperty:SelectProperty(property, propertySuffix)
	local suffixLen = #propertySuffix
	local result = {}
	for key, value in pairs(property) do
		if string.sub(key, -suffixLen) == propertySuffix then
			local baseKey = string.sub(key, 1, #key - suffixLen)
			result[baseKey] = value
		end
	end
	return result
end

-- 属性表相加
function PlayerProperty:PropertyCombineAdd(result, property)
	for key, value in pairs(property) do
		if result[key] == nil then
			result[key] = 0
		end
		result[key] = result[key] + value
	end
end

-- 属性表相乘
function PlayerProperty:PropertyCombineMultiple(result, property)
	for key, value in pairs(property) do
		if result[key] == nil then
			result[key] = 0
		end
		result[key] = result[key] * value
	end
end

return PlayerProperty
