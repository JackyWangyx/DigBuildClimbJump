local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)

local UIPropItem = {}

function UIPropItem:Init(root)
	local name = root.Name
	local key = string.match(name, "_(.+)$")
	UIButton:Handle(root.Button_Buy, function()
		UIPropItem:Buy(key)
	end)
	
	UIButton:Handle(root.Button_Use, function()
		UIPropItem:Use(key)
	end)
end

function UIPropItem:Buy(key)
	local data = ConfigManager:SearchData("Prop", "ProductKey", key)
	IAPClient:Purchase(data.ProductKey, function(success)
		if success then
			EventManager:Dispatch(EventManager.Define.RefreshProp)
		end
	end)
end

function UIPropItem:Use(key)
	local data = ConfigManager:SearchData("Prop", "ProductKey", key)
	NetClient:Request("Prop", "Use", { ID = data.ID }, function(result)
		EventManager:Dispatch(EventManager.Define.RefreshProp)
	end)	
end

return UIPropItem
