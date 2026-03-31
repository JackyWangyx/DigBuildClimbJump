local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)
local IAPHandler = require(game.ServerScriptService.ScriptAlias.IAPHandler)

local Define = require(game.ReplicatedStorage.Define)

local IAPServer = {}

IAPServer.PurchaseRequestInfoCache = {}

-- [Sample] 购买请求信息
local PurchaseRequestInfo = {
	PlayerID = nil,
	RequestID = nil,
	ProductID = nil,
	PurchaseTime = nil,
	Param = nil,
}

-- [Sample] 购买记录数据
local PurchaseRecordData = {
	PlayerID = nil,
	RequestID = nil,
	ProductID = nil,
	ProductKey = nil,
	PurchaseTime = nil,
	CompleteTime = nil,
}

function IAPServer:Init()
	MarketplaceService.ProcessReceipt = function(receiptInfo)
		return IAPServer:OnProcessReceipt(receiptInfo)
	end

	Players.PlayerAdded:Connect(function(player)
		IAPServer:OnPlayerAdded(player)
	end)
	
	Players.PlayerRemoving:Connect(function(player)
		IAPServer:OnPlayerRemoved(player)
	end)
end

-- 当玩家加入游戏，检查所有通行证，如果有则处理通行证效果
function  IAPServer:OnPlayerAdded(player)
	
end

function IAPServer:OnPlayerRemoved(player)
	for requestId, info in pairs(IAPServer.PurchaseRequestInfoCache) do
		if info.PlayerID == player.UserId then
			IAPServer.PurchaseRequestInfoCache[requestId] = nil
		end
	end
end

-- 接受到支付请求，仅 Develop Product 购买会自动触发
function  IAPServer:OnProcessReceipt(receiptInfo)
	local productID = receiptInfo.ProductId
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	-- 玩家不再游戏中
	if not player then 
		IAPServer:OnPurchaseFailed(player, receiptInfo, Define.Message.IAPNotInGame)
		return Enum.ProductPurchaseDecision.NotProcessedYet 
	end
	
	local iapData = ConfigManager:SearchData("IAP", "ProductID", productID)
	if not iapData then
		IAPServer:OnPurchaseFailed(player, receiptInfo, Define.Message.IAPPurchaseFailed)
		return Enum.ProductPurchaseDecision.NotProcessedYet 
	end
	
	local productKey = iapData.ProductKey
	local purchaseRequestInfo = Util:TableFind(IAPServer.PurchaseRequestInfoCache, function(info)
		return info.PlayerID == player.UserId and info.ProductID == productID
	end)
	
	-- 购买发起记录缺失
	if purchaseRequestInfo == nil then 
		IAPServer:OnPurchaseFailed(player, receiptInfo, Define.Message.IAPRequestNotFound)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	local requestID = purchaseRequestInfo.RequestID
	-- 处理通用商店购买
	local processResult = nil
	if Util:IsStrStartWith(productKey, "ProductStore") then
		local function extract_parts(name)
			local prefix, middle, suffix = name:match("^(ProductStore)(%a+)(%d+)$")
			return middle, suffix
		end
		
		local storeName, id = extract_parts(productKey)
		purchaseRequestInfo.Param = {}
		purchaseRequestInfo.Param.StoreName = storeName
		purchaseRequestInfo.Param.ID = id
		processResult = IAPHandler:HandleProductStore(player, purchaseRequestInfo.Param)
	else
		local processFunc = IAPHandler[productKey]
		-- 处理函数缺失
		if processFunc == nil or typeof(processFunc) ~= "function" then 
			IAPServer:OnPurchaseFailed(player, receiptInfo, Define.Message.IAPProcessNotFound)
			IAPServer.PurchaseRequestInfoCache[requestID] = nil
			return Enum.ProductPurchaseDecision.NotProcessedYet 
		end

		-- 处理发放购买物品，能否重复购买由具体业务判断
		processResult = processFunc(IAPHandler, player, purchaseRequestInfo.Param)
	end
	
	-- 记录购买
	if processResult then
		-- 购买记录
		local saveInfo = PlayerPrefs:GetModule(player, "IAP")
		local iapRecordData = {
			PlayerID = player.UserId,
			RequestID = requestID,
			ProductID = productID,
			ProductKey = productKey,
			PurchaseTime = purchaseRequestInfo.PurchaseTime,
			CompleteTime = os.time(),
		}
		
		if not saveInfo.History then saveInfo.History = {} end
		table.insert(saveInfo.History, iapRecordData)
		
		-- 计数
		IAPServer:SavePurchaseCount(player, productKey)
	end
	
	if not processResult then
		IAPServer:OnPurchaseFailed(player, receiptInfo, Define.Message.IAPPurchaseFailed)
		IAPServer.PurchaseRequestInfoCache[requestID] = nil
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	NetServer:Broadcast(player, "IAP", "OnPurchase", { 
		Result = Define.IAPResult.Complete,
		Message = "Success",
		ReceiptInfo = receiptInfo }
	)
	
	IAPServer.PurchaseRequestInfoCache[requestID] = nil
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

function IAPServer:SavePurchaseCount(player, productKey)
	local saveInfo = PlayerPrefs:GetModule(player, "IAP")
	if not saveInfo.PurchaseCounter then saveInfo.PurchaseCounter = {} end
	local counter = saveInfo.PurchaseCounter[productKey]
	if not counter then 
		saveInfo.PurchaseCounter[productKey] = 1
	else
		saveInfo.PurchaseCounter[productKey] = counter + 1
	end
end

-- 用于补发 GamePass 奖励
function IAPServer:ProcessPurchaseGamePass(player, productID)
	local iapData = ConfigManager:SearchData("IAP", "ProductID", productID)
	if not iapData then
		return false
	end
	local productKey = iapData.ProductKey
	local processFunc = IAPHandler[productKey]
	local processResult = processFunc(IAPHandler, player)
	return processResult
end

function IAPServer:OnPurchaseFailed(player, receiptInfo, message)
	NetServer:Broadcast(player, "IAP", "OnPurchase", { 
		Result = Define.IAPResult.Failed,
		Message = message,
		ReceiptInfo = receiptInfo }
	)
end

function IAPServer:CheckHasGamePass(player, productKey)
	local iapData = ConfigManager:SearchData("IAP", "ProductKey", productKey)
	if not iapData then 
		warn("[IAP Server] IAPData not found! Key : ", productKey)
		return false
	end

	-- 尝试一次，如果失败，则启用重试机制，成功后主动通知刷新
	local productID = iapData.ProductID
	local success, hasPass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, productID)
	end)

	if success then
		return hasPass
	else
		task.spawn(function()
			IAPServer:RetryCheckGamePass(player, productID)
		end)
	end

	return false
end

function IAPServer:RetryCheckGamePass(player, productID)
	local maxRetries = 5
	local retries = 0
	
	local iapData = ConfigManager:SearchData("IAP", "ProductID", productID)
	local productKey = iapData.ProductKey	
	
	while retries < maxRetries do
		local success, hasPass = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(player.UserId, productID)
		end)
		
		if success then
			if hasPass then
				IAPServer:SavePurchaseCount(player, productKey)
				EventManager:DispatchToClient(player, EventManager.Define.RefreshGamePass)
			else
				return
			end
		else
			retries += 1
			task.wait(0.5)
		end
	end
	
	warn("[IAP Server] Cannot check GamePass : ", productKey, productID, retries)
end

return IAPServer
