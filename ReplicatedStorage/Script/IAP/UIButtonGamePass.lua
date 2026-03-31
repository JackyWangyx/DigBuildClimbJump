local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local UIButtonGamePass = {}

function UIButtonGamePass:Handle(button)
	local productKey = UIButtonGamePass:GetProductKey(button)
	local iapData = ConfigManager:SearchData("IAP", "ProductKey", productKey)
	if not iapData or iapData.Type ~= "GamePass" then return end
	
	UIButtonGamePass:Refresh(button)
	UIButton:Handle(button, function()
		IAPClient:CheckHasGamePass(productKey, function(result)
			if result then
				UIButtonGamePass:Refresh(button, true)
				return
			else
				IAPClient:Purchase(productKey, function(result)
					UIButtonGamePass:Refresh(button, result)
				end)
			end
		end)
	end)
	
	EventManager:Listen(EventManager.Define.RefreshGamePass, function()
		IAPClient:CheckHasGamePass(productKey, function(result)
			UIButtonGamePass:Refresh(button, result)
		end)
	end)
end

function UIButtonGamePass:Refresh(button, hasPass)
	local productKey = UIButtonGamePass:GetProductKey(button)
	local togglePurchased = Util:GetChildByName(button, "Toggle_Purchased")
	local togglePurchasedTrue = Util:GetChildByName(button, "Toggle_Purchased_True")
	local togglePurchasedFlase = Util:GetChildByName(button, "Toggle_Purchased_False")
	local function RefreshImpl()
		if togglePurchased then
			togglePurchased.Visible = hasPass
		end

		if togglePurchasedTrue then
			togglePurchasedTrue.Visible = hasPass
		end

		if togglePurchasedFlase then
			togglePurchasedFlase.Visible = not hasPass
		end

		-- 刷新内购状态同时刷新所属UI
		local ui = Util:GetParentByType(button, "ScreenGui")
		if ui then
			local uiInfo = UIManager:GetPage(ui.Name)
			if uiInfo and uiInfo.RefreshFunc then
				uiInfo.RefreshFunc(uiInfo.Script)
			end
		end
	end
	
	if not hasPass then
		IAPClient:CheckHasGamePass(productKey, function(result)
			hasPass = result
			RefreshImpl()
		end)
	else
		RefreshImpl()
	end
end

function UIButtonGamePass:GetProductKey(button)
	local buttonName = button.Name
	local productKey = string.match(buttonName, "Button_(.-)_GamePass")
	return productKey
end

return UIButtonGamePass
