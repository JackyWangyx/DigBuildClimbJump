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
local TimerManager = require(game.ReplicatedStorage.ScriptAlias.TimerManager)
local TimeUtil = require(game.ReplicatedStorage.ScriptAlias.TimeUtil)
local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local RewardUtil = require(game.ReplicatedStorage.ScriptAlias.RewardUtil)

local Define = require(game.ReplicatedStorage.Define)

local UISignOnline = {}

UISignOnline.UIRoot = nil
UISignOnline.ItemList = nil
UISignOnline.InfoList = nil
UISignOnline.RefreshTimer = nil

UISignOnline.MainSignOnlineButton = nil

function UISignOnline:Init(root)
	UISignOnline.UIRoot = root

	task.delay(0.5, function()
		local uiMain = UIManager:GetPage("UIMain")
		UISignOnline.MainSignOnlineButton = Util:GetChildByName(uiMain.UI, "Button_SignOnline")

		if UISignOnline.MainSignOnlineButton then
			TimerManager:Interval(0.5, function()
				UISignOnline:RefreshMainButton()
			end)
		end	
	end)
end

function UISignOnline:OnShow(param)
	UISignOnline.RefreshTimer = TimerManager:Interval(0.5, function()
		UISignOnline:Refresh()
	end)
end

function UISignOnline:OnHide()
	if UISignOnline.RefreshTimer then
		UISignOnline.RefreshTimer:Destroy()
		UISignOnline.RefreshTimer = nil
	end
end

function UISignOnline:Refresh()
	if not UISignOnline.InfoList then
		NetClient:Request("Sign", "GetOnlineList", { Key = "SignOnline" }, function(infoList)
			UISignOnline.InfoList = infoList
			UISignOnline:RefreshList()
		end)
	else
		UISignOnline:RefreshList()
	end
end

function UISignOnline:ProcessInfoList(infoList)
	for _, info in ipairs(infoList) do
		UISignOnline:ProcessInfo(info)
	end
end

function UISignOnline:ProcessInfo(info)
	local now = os.time()
	local seconds = info.RequireTime - (now - info.LoginTime)
	if seconds < 0 then
		if not info.IsGetReward then
			info.CanGetReward = true
		end

		info.RemainTime = Define.Message.CanGetRewardTip
	else
		info.RemainTime = TimeUtil:FormatSeconds(seconds)
	end
end

function UISignOnline:ClearCache()
	UISignOnline.InfoList = nil
end

function UISignOnline:RefreshList()
	UISignOnline:ProcessInfoList(UISignOnline.InfoList)
	RewardUtil:ProcessInfoList(UISignOnline.InfoList)
	UISignOnline.ItemList = UIList:LoadWithInfo(UISignOnline.UIRoot, "UISignOnlineItem", UISignOnline.InfoList)
	UIList:HandleItemList(UISignOnline.ItemList, UISignOnline, "UISignItem")
end

function UISignOnline:RefreshMainButton()
	if not UISignOnline.InfoList then
		NetClient:Request("Sign", "GetOnlineList", { Key = "SignOnline" }, function(infoList)
			UISignOnline.InfoList = infoList
		end)

		return
	end

	local nextInfo = nil
	for _, info in ipairs(UISignOnline.InfoList) do
		if not info.IsGetReward then
			nextInfo = info
			break
		end
	end

	if nextInfo then
		local buttonInfo = {
			RequireTime = nextInfo.RequireTime,
			LoginTime = nextInfo.LoginTime,
			RemainTime = "",
		}

		UISignOnline:ProcessInfo(buttonInfo)

		UIInfo:SetInfo(UISignOnline.MainSignOnlineButton, buttonInfo)
	else
		local buttonInfo = {
			RemainTime = ""
		}

		UIInfo:SetInfo(UISignOnline.MainSignOnlineButton, buttonInfo)
	end
end

function UISignOnline:Claim(index)
	if not UISignOnline.ItemList then return end
	NetClient:Request("Sign", "GetOnlineReward", { Key = "SignOnline", ID = index }, function(rewardList)
		UISignOnline:ClearCache()
		UISignOnline:Refresh()

		for _, data in ipairs(rewardList) do
			UIManager:ShowMessageWithIcon(data.Icon, "Got "..data.Description)
			task.wait()
		end

		EventManager:Dispatch(EventManager.Define.RefreshSignOnline)
	end)
end

function UISignOnline:Button_ClaimAll()
	if not UISignOnline.ItemList then return end
	NetClient:Request("Sign", "CheckOnlineComplete", { Key = "SignOnline" }, function(isComplete)
		if isComplete then return end
		IAPClient:Purchase("SignOnlineGetAll", function(success)
			if not success then return end
			NetClient:Request("Sign", "GetAllOnlineReward", { Key = "SignOnline" }, function(rewardList)
				UISignOnline:ClearCache()
				UISignOnline:Refresh()

				for _, data in ipairs(rewardList) do
					UIManager:ShowMessageWithIcon(data.Icon, "Got "..data.Description)
					task.wait(0.1)
				end

				EventManager:Dispatch(EventManager.Define.RefreshSignOnline)
			end)
		end)
	end)
end

return UISignOnline
