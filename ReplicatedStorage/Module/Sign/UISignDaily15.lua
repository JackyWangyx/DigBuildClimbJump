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

local UISignDaily15 = {}

UISignDaily15.UIRoot = nil
UISignDaily15.ItemList = nil

function UISignDaily15:Init(root)
	UISignDaily15.UIRoot = root
end

function UISignDaily15:OnShow(param)

end

function UISignDaily15:OnHide()

end

function UISignDaily15:Refresh()
	NetClient:Request("Sign", "GetDailyList", { Key = "SignDaily15" }, function(infoList)
		UISignDaily15.ItemList = UIList:LoadWithInfo(UISignDaily15.UIRoot, "UISignDaily15Item", infoList)
		UIList:HandleItemList(UISignDaily15.ItemList, UISignDaily15, "UISignItem")
	end)
end

function UISignDaily15:Claim(index)
	if not UISignDaily15.ItemList then return end
	NetClient:Request("Sign", "GetDailyReward", { Key = "SignDaily15", ID = index }, function(rewardList)
		UISignDaily15:Refresh()
		for _, data in pairs(rewardList) do
			UIManager:ShowMessageWithIcon(data.Icon, "Got "..data.Description)
			task.wait()
		end
		EventManager:Dispatch(EventManager.Define.RefreshSignDaily)
	end)
end

return UISignDaily15
