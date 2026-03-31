local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local IAPHandler = {}

-----------------------------------------------------------------------------------------------

-- [Develop Product]

-- 通用商店购买
function IAPHandler:HandleProductStore(player, param)
	local storeName = param.StoreName
	local id = tonumber(param.ID)
	local result = { Success = false }
	if storeName == "Tool" then
		local toolRequest = NetServer:RequireModule("Tool")
		result = toolRequest:Buy(player, {ID = id})
	end

	if storeName == "Trail" then
		local trailRequest = NetServer:RequireModule("Trail")
		result = trailRequest:Buy(player, {ID = id})
	end
	
	if storeName == "Partner" then
		local partnerRequest = NetServer:RequireModule("Partner")
		result = partnerRequest:Buy(player, {ID = id})
	end
	
	if storeName == "Pet" then
		local petRequest = NetServer:RequireModule("Pet")
		local ret = petRequest:Add(player, { ID = id })
		result.Success = ret
	end
	
	if storeName == "Animal" then
		local animalRequest = NetServer:RequireModule("Animal")
		local ret = animalRequest:Add(player, { ID = id })
		result.Success = ret
	end
	
	if storeName == "Package" then
		local rewardList = ConfigManager:SearchAllData("RewardPackage", "PackageID", id)
		local rewardUtil = require(game.ServerScriptService.ScriptAlias.RewardUtil)
		rewardUtil:GetRewardList(player, rewardList)

		local iapRequest =  NetServer:RequireModule("IAP")
		iapRequest:BuyPackage(player, { ID = id } )
		result.Success = true
	end

	return result.Success
end

-- 合成宠物
function IAPHandler:CraftPet(player, param)
	local petRequest = NetServer:RequireModule("Pet")
	local result = petRequest:CraftRobux(player, {
		InstanceID = param.InstanceID
	})

	return result
end

-- 扩容宠物装备
function IAPHandler:AddPetEquip(player, param)
	local petRequest = NetServer:RequireModule("Pet")
	local result = petRequest:AddEquipMax(player)
	return result
end

-- 扩容宠物背包
function IAPHandler:AddPetPackage(player, param)
	local petRequest = NetServer:RequireModule("Pet")
	local result = petRequest:AddPackageMax(player)
	return result
end

function IAPHandler:AddAnimalPackage(player, param)
	local animalRequest = NetServer:RequireModule("Animal")
	local result = animalRequest:AddPackageMax(player)
	return result
end

-------------------------------------------------------------------------------------------------------
-- LuckyWheel

function IAPHandler:LuckyWheelX1(player, param)
	local luckyWheelRequest = NetServer:RequireModule("LuckyWheel")
	luckyWheelRequest:Buy(player, { Value = 1 })
	return true
end

function IAPHandler:LuckyWheelX10(player, param)
	local luckyWheelRequest = NetServer:RequireModule("LuckyWheel")
	luckyWheelRequest:Buy(player, { Value = 10 })
	return true
end

function IAPHandler:LuckyWheelX100(player, param)
	local luckyWheelRequest = NetServer:RequireModule("LuckyWheel")
	luckyWheelRequest:Buy(player, { Value = 100 })
	return true
end

-------------------------------------------------------------------------------------------------------
-- Sign
function IAPHandler:SignOnlineGetAll(player, param)
	return true
end

-- Rebirth

function IAPHandler:RebirthSkip(player, param)
	return true
end

-------------------------------------------------------------------------------------------------------
-- Activity

-- PetEggX1Christmas2025
function IAPHandler:PetEggX1Christmas2025(player, param)
	return true
end

-- PetEggX3Christmas2025
function IAPHandler:PetEggX3Christmas2025(player, param)
	return true
end

-- PetEggX9Christmas2025
function IAPHandler:PetEggX9Christmas2025(player, param)
	return true
end

function IAPHandler:SignDailyGetAllChristmas2025(player, param)
	return true
end

-------------------------------------------------------------------------------------------------------
-- PetLoot

-- SlimePetEggX1
function IAPHandler:SlimePetEggX1(player, param)
	return true
end

-- SlimePetEggX3
function IAPHandler:SlimePetEggX3(player, param)
	return true
end

-- SlimePetEggX9
function IAPHandler:SlimePetEggX9(player, param)
	return true
end

-- BrainrotPetEggX1
function IAPHandler:BrainrotPetEggX1(player, param)
	return true
end

-- BrainrotPetEggX3
function IAPHandler:BrainrotPetEggX3(player, param)
	return true
end

-- BrainrotPetEggX9
function IAPHandler:BrainrotPetEggX9(player, param)
	return true
end

-- 购买工具
function IAPHandler:BuyTool(player, param)
	return true
end

-- 购买拖尾
function IAPHandler:BuyTrail(player, param)
	return true
end

----------------------------------------------------------------------------
-- RollerCoaster Track (Robux)

function IAPHandler:ProductRail60(player, param)
	return true
end

function IAPHandler:ProductRail100(player, param)
	return true
end

function IAPHandler:ProductRail150(player, param)
	return true
end

function IAPHandler:ProductRail230(player, param)
	return true
end

function IAPHandler:ProductRail350(player, param)
	return true
end

function IAPHandler:ProductRail500(player, param)
	return true
end

----------------------------------------------------------------------------
-- Account Coin

function IAPHandler:Coin300K(player, param)
	local accountRequest = NetServer:RequireModule("Account")
	accountRequest:AddCoin(player, { Value = 300000 })
	return true
end

function IAPHandler:Coin2M(player, param)
	local accountRequest = NetServer:RequireModule("Account")
	accountRequest:AddCoin(player, { Value = 2000000 })
	return true
end

function IAPHandler:Coin10M(player, param)
	local accountRequest = NetServer:RequireModule("Account")
	accountRequest:AddCoin(player, { Value = 10000000 })
	return true
end

function IAPHandler:Coin25M(player, param)
	local accountRequest = NetServer:RequireModule("Account")
	accountRequest:AddCoin(player, { Value = 25000000 })
	return true
end

function IAPHandler:Coin45M(player, param)
	local accountRequest = NetServer:RequireModule("Account")
	accountRequest:AddCoin(player, { Value = 45000000 })
	return true
end

function IAPHandler:Coin100M(player, param)
	local accountRequest = NetServer:RequireModule("Account")
	accountRequest:AddCoin(player, { Value = 100000000 })
	return true
end

function IAPHandler:Coin500M(player, param)
	local accountRequest = NetServer:RequireModule("Account")
	accountRequest:AddCoin(player, { Value = 500000000 })
	return true
end

----------------------------------------------------------------------------
-- Account Wins

function IAPHandler:Wins10K(player, param)
	local accountRequest = NetServer:RequireModule("Account")
	accountRequest:AddWins(player, { Value = 10000 })
	return true
end

-- Prop
function IAPHandler:DoublePowerX5(player, param)
	local propRequest = NetServer:RequireModule("Prop")
	local data = ConfigManager:SearchData("Prop", "ProductKey", "DoublePowerX5")
	propRequest:Buy(player, { ID = data.ID })
	return true
end

function IAPHandler:DoubleCoinsX5(player, param)
	local propRequest = NetServer:RequireModule("Prop")
	local data = ConfigManager:SearchData("Prop", "ProductKey", "DoubleCoinsX5")
	propRequest:Buy(player, { ID = data.ID })
	return true
end

function IAPHandler:DoubleWinsX5(player, param)
	local propRequest = NetServer:RequireModule("Prop")
	local data = ConfigManager:SearchData("Prop", "ProductKey", "DoubleWinsX5")
	propRequest:Buy(player, { ID = data.ID })
	return true
end

function IAPHandler:DoubleSpeedX5(player, param)
	local propRequest = NetServer:RequireModule("Prop")
	local data = ConfigManager:SearchData("Prop", "ProductKey", "DoubleSpeedX5")
	propRequest:Buy(player, { ID = data.ID })
	return true
end

function IAPHandler:GoldHatch(player, param)
	local propRequest = NetServer:RequireModule("Prop")
	local data = ConfigManager:SearchData("Prop", "ProductKey", "GoldHatch")
	propRequest:Buy(player, { ID = data.ID })
	return true
end

function IAPHandler:LuckyHatch(player, param)
	local propRequest = NetServer:RequireModule("Prop")
	local data = ConfigManager:SearchData("Prop", "ProductKey", "LuckyHatch")
	propRequest:Buy(player, { ID = data.ID })
	return true
end

-------------------------------------------------------------------------------------------------------
-- Quest

function IAPHandler:SkipQuestSeason(player, param)
	return true
end

function IAPHandler:UnlockAllSeasonQuest(player, param)
	return true
end

function IAPHandler:SeasonPass(player, param)
	local questRequest = require(game.ServerScriptService.ScriptAlias.Quest)
	local saveInfo = questRequest:GetInfo(player)
	saveInfo.SeasonPass = true
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	return true
end

-------------------------------------------------------------------------------------------------------

-- [Game Pass]

function IAPHandler:AutoPlay(player, param)
	return true
end

-- SuperLuck
function IAPHandler:SuperLuck(player, param)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	return true
end

-- UltraLuck
function IAPHandler:UltraLuck(player, param)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	return true
end

-- SecretHunter
function IAPHandler:SecretHunter(player, param)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	return true
end

-- FastHatch
function IAPHandler:FastHatch(player, param)
	-- 跳过抽奖动画，使用时直接判断是否购买即可
	return true
end

-- HatchX3
function IAPHandler:HatchX3(player, param)
	-- 一次开三个，使用时直接判断是否购买即可
	return true
end

-- AutoHatch
function IAPHandler:AutoHatch(player, param)
	-- 自动开奖直到没钱，使用时直接判断是否购买即可
	return true
end

-- AutoRebirth
function IAPHandler:AutoRebirth(player, param)
	local autoRebirth = require(game.ServerScriptService.ScriptAlias.AutoRebirthHandler)
	autoRebirth:AddPlayer(player)
	return true
end

-- VIP
function IAPHandler:VIP(player, param)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	return true
end

-- Get Power X2
function IAPHandler:GetPowerX2(player ,param)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	return true
end

-- Win X2
function IAPHandler:WinX2(player ,param)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	return true
end

-- Coin X2
function IAPHandler:CoinX2(player ,param)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	return true
end

-- MaxSpeed X2
function IAPHandler:MaxSpeedX2(player ,param)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	return true
end

function IAPHandler:AutoClick(player, param)
	EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	return true
end

return IAPHandler
