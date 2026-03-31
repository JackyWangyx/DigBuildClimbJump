local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)

local UIButtonNewbiePack = {}

function UIButtonNewbiePack:Handle(button)
	local productKey = UIButtonNewbiePack:GetProductKey(button)
	local storeInfo = UIButtonNewbiePack:GetStoreInfo(productKey)
	local storeName = storeInfo.StoreName
	
	--print(button.Name, storeInfo)
	if not storeName then return end
	
	local packageID = storeInfo.ID
	local iapData = ConfigManager:SearchData("IAP", "ProductKey", productKey)
	if not iapData or iapData.Type ~= "Product" then return end
	
	task.wait()
	
	local function RefreshFunc()
		NetClient:Request("IAP", "GetPackageCount", { ID = packageID }, function(count)
			local isBuy = count > 0
			UIButtonNewbiePack:Refresh(button, isBuy)
		end)
	end
	
	RefreshFunc()
	
	UIButton:Handle(button, function()
		NetClient:Request("IAP", "GetPackageCount", { ID = packageID }, function(count)
			local isBuy = count > 0
			if isBuy then
				UIButtonNewbiePack:Refresh(button, true)
				return
			else
				IAPClient:Purchase(productKey, function(result)
					if result then
						RefreshFunc()
						
						local rewardList = ConfigManager:SearchAllData("RewardPackage", "PackageID", packageID)
						for _, data in ipairs(rewardList) do
							if data.Icon then
								UIManager:ShowMessageWithIcon(data.Icon, "Got "..data.Description)
								task.wait(0.1)
							end
						end
					end
				end)
			end
		end)
	end)
end

function UIButtonNewbiePack:Refresh(button, isBuy)
	local productKey = UIButtonNewbiePack:GetProductKey(button)
	local togglePurchased = Util:GetChildByName(button, "Toggle_Purchased")
	local togglePurchasedTrue = Util:GetChildByName(button, "Toggle_Purchased_True")
	local togglePurchasedFlase = Util:GetChildByName(button, "Toggle_Purchased_False")
	
	if togglePurchased then
		togglePurchased.Visible = isBuy
	end

	if togglePurchasedTrue then
		togglePurchasedTrue.Visible = isBuy
	end

	if togglePurchasedFlase then
		togglePurchasedFlase.Visible = not isBuy
	end
end

function UIButtonNewbiePack:GetStoreInfo(productKey)
	if Util:IsStrStartWith(productKey, "ProductStore") then
		local function extract_parts(name)
			local prefix, middle, suffix = name:match("^(ProductStore)(%a+)(%d+)$")
			return middle, suffix
		end
		local storeName, id = extract_parts(productKey)
		return { 
			StoreName = storeName, 
			ID = tonumber(id) 
		}
	else
		return { 
			StoreName = nil, 
			ID = nil 
		}
	end
end

function UIButtonNewbiePack:GetProductKey(button)
	local buttonName = button.Name
	local productKey = string.match(buttonName, "Button_(.-)_NewbiePack")
	return productKey
end

return UIButtonNewbiePack
