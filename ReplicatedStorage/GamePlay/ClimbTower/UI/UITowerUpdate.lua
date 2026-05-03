local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local ObjectInfo = require(game.ReplicatedStorage.ScriptAlias.ObjectInfo)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local UIListSelect = require(game.ReplicatedStorage.ScriptAlias.UIListSelect)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local UIConfirm = require(game.ReplicatedStorage.ScriptAlias.UIConfirm)
local TweenUtil = require(game.ReplicatedStorage.ScriptAlias.TweenUtil)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local ClimbTowerDefine = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerDefine)

local UITowerUpdate = {}

UITowerUpdate.UIRoot = nil
UITowerUpdate.MaxFrame = nil
UITowerUpdate.TowerInfo = nil

function UITowerUpdate:Init(root)
	UITowerUpdate.UIRoot = root
	UITowerUpdate.MaxFrame = Util:GetChildByName(UITowerUpdate.UIRoot, "MaxFrame")
end

function UITowerUpdate:OnShow()

end

function UITowerUpdate:OnHide()

end

function UITowerUpdate:Refresh()
	local info = NetClient:RequestWait("ClimbTower", "GetTowerStoreInfo")
	UIInfo:SetInfo(UITowerUpdate.UIRoot, info)
	UITowerUpdate.TowerInfo = info
end

function UITowerUpdate:Button_Buy()
	NetClient:Request("ClimbTower", "UpgradeTower", { Type = "Power" }, function(result)
		if result.Success then
			UITowerUpdate:Refresh()
			EventManager:Dispatch(ClimbTowerDefine.Event.RefreshTower)
		else
			UIManager:ShowMessage(result.Message)
		end
	end)
end

function UITowerUpdate:Button_BuyRobux()
	if not UITowerUpdate.TowerInfo then return end
	IAPClient:Purchase( UITowerUpdate.TowerInfo.ProductKey, function(success)
		if success then
			NetClient:Request("ClimbTower", "UpgradeTower", { Type = "Robux" }, function(result)
				if result.Success then
					UITowerUpdate:Refresh()
					EventManager:Dispatch(ClimbTowerDefine.Event.RefreshTower)
				else
					UIManager:ShowMessage(result.Message)
				end
			end)
		end
	end)
end

return UITowerUpdate
