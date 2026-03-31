local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local AttributeUtil = require(game.ReplicatedStorage.ScriptAlias.AttributeUtil)
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

local UIRebirth = {}

UIRebirth.UIRoot = nil
UIRebirth.MaxFrame = nil

function UIRebirth:Init(root)
	UIRebirth.UIRoot = root
	UIRebirth.MaxFrame = Util:GetChildByName(UIRebirth.UIRoot, "MaxFrame")
	
	EventManager:Listen(EventManager.Define.RefreshRebirth, function()
		UIRebirth:Refresh()
	end)
end

function UIRebirth:OnShow()

end

function UIRebirth:OnHide()

end

function UIRebirth:Refresh()
	NetClient:Request("Rebirth", "GetUIInfo", function(info)
		IAPClient:CheckHasGamePass("AutoRebirth", function(hasGamePass)
			if info then
				info.IsPurchased = hasGamePass
				UIRebirth.MaxFrame.Visible = false
				UIInfo:SetInfo(UIRebirth.UIRoot, info)
			else
				UIRebirth.MaxFrame.Visible = true
			end
		end)	
	end)
end

function UIRebirth:Button_Rebirth()
	NetClient:Request("Rebirth", "RebirthManual", function(result)
		if result.Success then
			task.wait()
			UIRebirth:Refresh()
			EventManager:Dispatch(EventManager.Define.RefreshRebirth)
		else
			UIManager:ShowMessage(result.Message)
		end
	end)
end

function UIRebirth:Button_RebirthSkip()
	IAPClient:Purchase("RebirthSkip", function(susccess)
		if susccess then
			NetClient:Request("Rebirth", "RebirthSkip", function(result)
				if result.Success then
					task.wait()
					UIRebirth:Refresh()
					EventManager:Dispatch(EventManager.Define.RefreshRebirth)
				else
					UIManager:ShowMessage(result.Message)
				end
			end)
		end
	end)
end

function UIRebirth:Button_AutoOn()
	NetClient:Request("Rebirth", "SwitchAuto", function()
		UIRebirth:Refresh()
	end)
end

function UIRebirth:Button_AutoOff()
	NetClient:Request("Rebirth", "SwitchAuto", function()
		UIRebirth:Refresh()
	end)
end

function UIRebirth:Button_AutoRebirth()
	IAPClient:Purchase("AutoRebirth", function(success)
		if success then
			UIRebirth:Refresh()
		end
	end)
end

return UIRebirth
