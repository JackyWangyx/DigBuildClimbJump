local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)

local UIButtonDevelopProduct = {}

function UIButtonDevelopProduct:Handle(button)
	local productKey = UIButtonDevelopProduct:GetProductKey(button)
	local iapData = ConfigManager:SearchData("IAP", "ProductKey", productKey)
	if not iapData or iapData.Type ~= "Product" then return end
	UIButtonDevelopProduct:Refresh(button)
	UIButton:Handle(button, function()
		IAPClient:Purchase(productKey, function(result)
			UIButtonDevelopProduct:Refresh(button)
		end)
	end)
end

function UIButtonDevelopProduct:Refresh(button)
	--if string.find(button.Name, "ProductStorePackage") then
	--	local packageID = tonumber(string.match(button.Name, "ProductStorePackage(%d+)"))
	--	NetClient:Request("IAP", "GetPackageInfo", { ID = packageID }, function(result)
	--		if result.Count > 0 then
	--			button.Visible = false				
	--		else
	--			button.Visible = true
	--		end
	--	end)
	--end
end

function UIButtonDevelopProduct:GetProductKey(button)
	local buttonName = button.Name
	local productKey = string.match(buttonName, "Button_(.-)_DevelopProduct")
	return productKey
end

return UIButtonDevelopProduct
