local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)

local IAP = {}

IAP.Icon = "💳"
IAP.Color = Color3.new(0.358679, 0.922789, 0.937728)

function IAP:History(player, param)
	local history = PlayerPrefs:GetModule(player, "IAP").History
	print(history)
end

function IAP:Count(player, param)
	local module = PlayerPrefs:GetModule(player, "IAP")
	print("Purchase", module.PurchaseCounter)
	print("Package", module.PackageCounter)
end

function IAP:Clear(player, param)
	PlayerPrefs:SetModule(player, "IAP", nil)
end

return IAP
