local MarketplaceService = game:GetService("MarketplaceService")

local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)

local IAPServer = require(game.ServerScriptService.ScriptAlias.IAPServer)
local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)

local IAP = {}

local PetDataTemplate = {
	PurchaseCounter = {
		["Key1"] = 1,
		["Key2"] = 2,
	},
	PackageCounter = {
		["ID 1"] = 1,
		["ID 2"] = 2,
	}
}

function LoadInfo(player)
	local saveInfo = PlayerPrefs:GetModule(player, "IAP")
	return saveInfo
end

function IAP:BuyPackage(player, param)
	local packageID = tostring(param.ID)
	local saveInfo = LoadInfo(player)
	if not saveInfo.PackageCounter then
		saveInfo.PackageCounter = {}
	end
	
	local count = saveInfo.PackageCounter[packageID]
	if not count then
		count = 0
	end
	
	count += 1
	saveInfo.PackageCounter[packageID] = count

	return true
end

function IAP:GetPackageCount(player, param)
	local packageID =  tostring(param.ID)
	local saveInfo = LoadInfo(player)
	if not saveInfo.PackageCounter then
		saveInfo.PackageCounter = {}
	end
	
	local count = saveInfo.PackageCounter[packageID]
	if not count then
		count = 0
		saveInfo.PackageCounter[packageID] = count
	end
	
	return count
end

function IAP:Purchase(player, param)
	local purchaseRequestInfo = {
		PlayerID = player.UserId,
		RequestID = param.RequestID,
		ProductID = param.ProductID,
		PurchaseTime = os.time(),
		Param = param.Param,
	}
	
	IAPServer.PurchaseRequestInfoCache[purchaseRequestInfo.RequestID] = purchaseRequestInfo
	return true
end

-- 服务端无法直接触发 GamePass 回调，首次购买成功由客户端通知，模拟触发，统一购买流程
function IAP:PurchaseGamePass(player, param)
	local receiptInfo = {
		ProductId = param.ProductID,
		PlayerId = player.UserId,
	}
	
	IAPServer:OnProcessReceipt(receiptInfo)
	return true
end

function IAP:GetProductInfo(player, param)
	local productID = param.ProductID
	local productInfo = MarketplaceService:GetProductInfo(productID)
	return productInfo
end

function IAP:CheckHasGamePass(player, param)
	local count = IAP:GetPurchaseCount(player, param)
	return count >= 1
end

function IAP:GetPurchaseCount(player, param)
	local productKey = param.ProductKey
	local iapData = ConfigManager:SearchData("IAP", "ProductKey", productKey)
	if not iapData then return 0 end
	
	-- 先从存储购买记录查询，再从内购服务查询
	local productID = iapData.ProductID
	local saveInfo = LoadInfo(player)
	local counterInfo = saveInfo.PurchaseCounter
	local result = 0
	if counterInfo ~= nil then
		local value = counterInfo[productKey]
		if value ~= nil then
			result = value
		else
			counterInfo[productKey] = 0
			result = 0
		end
	else
		counterInfo = {}
		saveInfo.PurchaseCounter = counterInfo
	end
	
	if result > 0 then
		return result
	end
	
	-- 通行证无购买记录则进行一次查询，并缓存结果
	if result == 0 and iapData.Type == "GamePass" then
		local hasGamePass = IAPServer:CheckHasGamePass(player, productKey)
		--print("Check", productKey, hasGamePass)
		if hasGamePass then
			-- 可查询到购买，但未被记录，说明奖励未发放，处理一次发放奖励
			local processResult = IAPServer:ProcessPurchaseGamePass(player, productID)
			if processResult then
				counterInfo[productKey] = 1
				result = 1
			end
		end
	end
	

	return result
end

return IAP