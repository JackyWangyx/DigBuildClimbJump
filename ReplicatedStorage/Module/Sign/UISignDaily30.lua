local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local AttributeUtil = require(game.ReplicatedStorage.ScriptAlias.AttributeUtil)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local UIListSelect = require(game.ReplicatedStorage.ScriptAlias.UIListSelect)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local Define = require(game.ReplicatedStorage.Define)

local UISignDaily30 = {}

UISignDaily30.UIRoot = nil
UISignDaily30.ItemList = nil

function UISignDaily30:Init(root)
	UISignDaily30.UIRoot = root
end

function UISignDaily30:OnShow(param)

end

function UISignDaily30:OnHide()

end

function UISignDaily30:Refresh()
	NetClient:Request("Sign", "GetDailyList", { Key = "SignDaily30" }, function(infoList)
		UISignDaily30.ItemList = UIList:LoadWithInfo(UISignDaily30.UIRoot, "UISignDaily30Item", infoList)
		UIList:HandleItemList(UISignDaily30.ItemList, UISignDaily30, "UISignItem")
	end)
end

function UISignDaily30:Claim(index)
	if not UISignDaily30.ItemList then return end
	NetClient:Request("Sign", "GetDailyReward", { Key = "SignDaily30", ID = index }, function(rewardList)
		UISignDaily30:Refresh()
		for _, data in pairs(rewardList) do
			UIManager:ShowMessageWithIcon(data.Icon, "Got "..data.Description)
			task.wait()
		end
		EventManager:Dispatch(EventManager.Define.RefreshSignDaily)
	end)
end

return UISignDaily30
