local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)

local Define = require(game.ReplicatedStorage.Define)

local IAP = {}

function IAP:OnPurchase(player, param)
	local iapResult = param.Result
	local message = param.Message
	local receiptInfo = param.ReceiptInfo
	local productID = receiptInfo.ProductId
	IAPClient:OnPurchase(productID, iapResult, message)
end

return IAP
