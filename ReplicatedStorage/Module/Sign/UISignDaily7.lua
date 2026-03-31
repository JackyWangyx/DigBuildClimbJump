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

local UISignDaily7 = {}

UISignDaily7.UIRoot = nil
UISignDaily7.ItemList = nil

function UISignDaily7:Init(root)
	UISignDaily7.UIRoot = root
end

function UISignDaily7:OnShow(param)

end

function UISignDaily7:OnHide()

end

function UISignDaily7:Refresh()
	NetClient:Request("Sign", "GetDailyList", { Key = "SignDaily7" }, function(infoList)
		UISignDaily7.ItemList = UIList:LoadWithInfo(UISignDaily7.UIRoot, nil, infoList)
		UIList:HandleItemList(UISignDaily7.ItemList, UISignDaily7, "UISignItem")
	end)
end

function UISignDaily7:Claim(index)
	if not UISignDaily7.ItemList then return end
	NetClient:Request("Sign", "GetDailyReward", { Key = "SignDaily7", ID = index }, function(rewardList)
		UISignDaily7:Refresh()
		for _, data in ipairs(rewardList) do
			UIManager:ShowMessageWithIcon(data.Icon, "Got "..data.Description)
			task.wait()
		end
		EventManager:Dispatch(EventManager.Define.RefreshSignDaily)
	end)
end

return UISignDaily7
