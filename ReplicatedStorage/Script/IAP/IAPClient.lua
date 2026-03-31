local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventMnaager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)

local Define = require(game.ReplicatedStorage.Define)

local IAPClient = {}

IAPClient.RequestList = {}
IAPClient.CallbackList = {}

function IAPClient:Init()
	-- 本地支付成功回调，非业务处理完成回调
	MarketplaceService.PromptProductPurchaseFinished:Connect(OnPurchaseProduct)
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(OnPurchaseGamePass)
end

function IAPClient:Purchase(productKey, param, callback)
	if callback == nil and typeof(param) == "function" then
		callback = param
		param = nil
	end
	
	local player = Players.LocalPlayer
	local iapData = ConfigManager:SearchData("IAP", "ProductKey", productKey)
	local iapList = ConfigManager:GetDataList("IAP")
	if not iapData then
		warn("[IAP Client] IAPData not found! "..productKey)
		return
	end
	
	UIManager:Cover("UIWaitLoading")
	
	local productId = iapData.ProductID
	
	-- 先向服务器提交购买记录，提交成功后发起购买请求
	local requestParam = {
		RequestID = Util:NewGuid(),
		ProductID = productId,
		Param = param
	}
	
	table.insert(IAPClient.RequestList, requestParam)
	NetClient:Request("IAP", "Purchase", requestParam, function(requestResult)
		local callbackInfo = {
			ProductKey = productKey,
			Callback = callback,
		}

		table.insert(IAPClient.CallbackList, callbackInfo)
		if iapData.Type == "Product" then
			MarketplaceService:PromptProductPurchase(player, productId)
		elseif iapData.Type == "GamePass" then
			MarketplaceService:PromptGamePassPurchase(player, productId)
		end
	end)
end

-- Client Callback
-- 处理 取消支付
function OnPurchaseProduct(player, productID, purchaseResult)
	if not purchaseResult then
		IAPClient:OnPurchase(productID, Define.IAPResult.Cancel, "Client cancel!")
	end
end

-- GamePass 只有客户端回调，首次完成购买由客户端通知服务器一次，再由服务器模拟触发，统一购买处理流程
function OnPurchaseGamePass(player, productID, purchaseResult)
	local requestParam = Util:ListFind(IAPClient.RequestList, function(item) return item.ProductID == productID end)
	if not requestParam then
		--warn("[IAP Clinet] OnPurchaseGamePass requestPram not found", productID, purchaseResult)
		requestParam = {
			RequestID = Util:NewGuid(),
			ProductID = productID,
			Param = nil
		}
	end
	
	if purchaseResult then
		if not requestParam.ProductID then
			requestParam.ProductID = productID
		end
	
		NetClient:Request("IAP", "PurchaseGamePass", requestParam, function(result)
			if result then
				EventMnaager:Dispatch(EventMnaager.Define.RefreshGamePass)
			end		
		end)
	else
		IAPClient:OnPurchase(productID, Define.IAPResult.Cancel, "Client cancel!")
	end
end

-- Server Callback
-- 处理 购买成功 / 失败
function IAPClient:OnPurchase(productID, iapResult, message)
	UIManager:Hide("UIWaitLoading")
	
	local success = iapResult == Define.IAPResult.Complete
	local iapData = ConfigManager:SearchData("IAP", "ProductID", productID)
	local callbackInfo = Util:ListFind(IAPClient.CallbackList, function(info) return info.ProductKey == iapData.ProductKey end)
	if callbackInfo then
		callbackInfo.Callback(success)
		Util:ListRemove(IAPClient.CallbackList, callbackInfo)
	end
	
	local requestPram = Util:ListFind(IAPClient.RequestList, function(item) return item.ProductID == productID end)
	if requestPram then
		Util:ListRemove(IAPClient.RequestList, requestPram)
	end
		
	if iapResult == Define.IAPResult.Failed then
		warn("[Client] Purchased "..iapData.ProductKey.." failed! "..message)
	end
	
	if iapResult == Define.IAPResult.Cancel and RunService:IsStudio() then
		warn("[Client] Purchased "..iapData.ProductKey.." failed! "..message)
	end
end

-- Check
function IAPClient:CheckHasGamePass(productKey, callback)
	NetClient:Request("IAP", "GetPurchaseCount", {ProductKey = productKey}, function(count)
		local result = count > 0
		if callback then
			callback(result)
		end	
	end)
end

function IAPClient:GetInfo(productKey)
	local iapData = ConfigManager:SearchData("IAP", "ProductKey", productKey)
	local productId = iapData.ProductID

	local infoType = nil
	if iapData.Type == "Prodcut" then
		infoType = Enum.InfoType.Product
	elseif iapData.Type == "GamePass" then
		infoType = Enum.InfoType.GamePass
	end

	if not infoType then
		warn("[Client] Invalid IAP type for productKey:", productKey)
		return nil
	end

	local success, info = pcall(function()
		return MarketplaceService:GetProductInfoAsync(productId, infoType)
	end)

	if success then
		return info
	else
		warn("[Client] Failed to get product info for ID", productId, ":", info)
		return nil
	end
end

return IAPClient
