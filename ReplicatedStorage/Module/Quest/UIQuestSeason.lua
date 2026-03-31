local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local AttributeUtil = require(game.ReplicatedStorage.ScriptAlias.AttributeUtil)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local UIListSelect = require(game.ReplicatedStorage.ScriptAlias.UIListSelect)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local UIConfirm = require(game.ReplicatedStorage.ScriptAlias.UIConfirm)
local PetUtil = require(game.ReplicatedStorage.ScriptAlias.PetUtil)
local TweenUtil = require(game.ReplicatedStorage.ScriptAlias.TweenUtil)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local TimeUtil = require(game.ReplicatedStorage.ScriptAlias.TimeUtil)
local TimerManager = require(game.ReplicatedStorage.ScriptAlias.TimerManager)

local UIQuestList = require(game.ReplicatedStorage.ScriptAlias.UIQuestList)
local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)

local Define = require(game.ReplicatedStorage.Define)

UIQuestSeason = {}

UIQuestSeason.UIRoot = nil

UIQuestSeason.PremiumFrame = nil
UIQuestSeason.QuestFrame = nil
UIQuestSeason.SeasonFrame = nil
UIQuestSeason.SeasonLootFrame = nil

UIQuestSeason.RefreshTimer = nil
UIQuestSeason.SeasonItemList = nil

UIQuestSeason.DailyFrame = nil
UIQuestSeason.DailyItemList = nil
UIQuestSeason.DailyCountDown = nil
UIQuestSeason.WeeklyFrame = nil
UIQuestSeason.WeeklyItemList = nil
UIQuestSeason.WeeklyCountDown = nil

UIQuestSeason.HasSeasonPass = false

function UIQuestSeason:Init(root)
	UIQuestSeason.UIRoot = root
	
	UIQuestSeason.PremiumFrame = Util:GetChildByName(root, "PremiumFrame")
	UIQuestSeason.QuestFrame = Util:GetChildByName(root, "QuestFrame")
	UIQuestSeason.SeasonFrame = Util:GetChildByName(root, "SeasonFrame")
	UIQuestSeason.SeasonLootFrame = Util:GetChildByName(root, "SeasonLootFrame")
	UIQuestSeason.PassFrame = Util:GetChildByName(UIQuestSeason.SeasonFrame, "PassFrame")
	
	UIQuestSeason.DailyFrame = Util:GetChildByName(UIQuestSeason.QuestFrame, "DailyFrame")
	UIQuestSeason.DailyCountDown = Util:GetChildByName(UIQuestSeason.DailyFrame, "Text_CountDown")
	UIQuestSeason.WeeklyFrame = Util:GetChildByName(UIQuestSeason.QuestFrame, "WeeklyFrame")
	UIQuestSeason.WeeklyCountDown = Util:GetChildByName(UIQuestSeason.WeeklyFrame, "Text_CountDown")
end

function UIQuestSeason:OnShow(param)
	UIQuestSeason:Button_Season()
	
	UIQuestSeason.RefreshTimer = TimerManager:Interval(1, function()
		UIQuestSeason:RefreshCountDown()
	end)
end

function UIQuestSeason:OnHide()
	if UIQuestSeason.RefreshTimer then
		UIQuestSeason.RefreshTimer:Destroy()
		UIQuestSeason.RefreshTimer = nil
	end
	
	UIQuestSeason.RefreshTimer = nil
end

function UIQuestSeason:Refresh()
	UIQuestSeason.HasSeasonPass = NetClient:RequestWait("Quest", "CheckSeasonPass")
	
	UIQuestSeason:RefreshPassInfo()
	UIQuestSeason:RefreshSeason() 
	UIQuestSeason:RefreshDaily()
	UIQuestSeason:RefreshWeekly()
end

function UIQuestSeason:RefreshPassInfo()
	NetClient:Request("Quest", "GetPassInfo", function(info)
		UIInfo:SetInfo(UIQuestSeason.PremiumFrame, info)
		UIInfo:SetInfo(UIQuestSeason.PassFrame, info)
	end)
end

function UIQuestSeason:RefreshSeason()
	local itemList = UIQuestList:Refresh(UIQuestSeason.SeasonFrame, self, QuestDefine.Type.Season, "UIQuestSeasonItem", "UIQuestItem")
	UIQuestSeason.SeasonItemList = itemList	
	
	local dataList = ConfigManager:GetDataList("QuestSeasonPremium")
	for index, item in ipairs(UIQuestSeason.SeasonItemList) do
		local data = dataList[index]
		data.HasSeasonPass = UIQuestSeason.HasSeasonPass
		AttributeUtil:SetData(item, data)
		UIInfo:SetInfo(item, data)
	end
end

function UIQuestSeason:RefreshDaily()
	local itemList = UIQuestList:Refresh(UIQuestSeason.DailyFrame, self, QuestDefine.Type.Daily, "UIQuestDailyItem", "UIQuestItem")
	UIQuestSeason.DailyItemList = itemList
end

function UIQuestSeason:RefreshWeekly()
	local itemList = UIQuestList:Refresh(UIQuestSeason.WeeklyFrame, self, QuestDefine.Type.Weekly, "UIQuestWeeklyItem", "UIQuestItem")
	UIQuestSeason.WeeklyItemList = itemList
end

function UIQuestSeason:RefreshCountDown()
	local dayLeft = TimeUtil:GetLeftToday()
	UIQuestSeason.DailyCountDown.Text = dayLeft
	local weekLeft = TimeUtil:GetLeftWeek()
	UIQuestSeason.WeeklyCountDown.Text = weekLeft
end

function UIQuestSeason:Button_Premium()
	UIQuestSeason.PremiumFrame.Visible = true
	UIQuestSeason.QuestFrame.Visible = false
	UIQuestSeason.SeasonFrame.Visible = false
	UIQuestSeason.SeasonLootFrame.Visible = false
end

function UIQuestSeason:Button_Quest()
	UIQuestSeason.PremiumFrame.Visible = false
	UIQuestSeason.QuestFrame.Visible = true
	UIQuestSeason.SeasonFrame.Visible = false
	UIQuestSeason.SeasonLootFrame.Visible = false
end

function UIQuestSeason:Button_Season()
	UIQuestSeason.PremiumFrame.Visible = false
	UIQuestSeason.QuestFrame.Visible = false
	UIQuestSeason.SeasonFrame.Visible = true
	UIQuestSeason.SeasonLootFrame.Visible = false
end

function UIQuestSeason:Button_SeasonLoot()
	UIQuestSeason.PremiumFrame.Visible = false
	UIQuestSeason.QuestFrame.Visible = false
	UIQuestSeason.SeasonFrame.Visible = false
	UIQuestSeason.SeasonLootFrame.Visible = true
end

function UIQuestSeason:GetReward(index)
	if not UIQuestSeason.SeasonItemList then return end
	local item = UIQuestSeason.SeasonItemList[index]
	local info = AttributeUtil:GetInfo(item)
	NetClient:Request("Quest", "GetReward", { Type = QuestDefine.Type.Season, ID = info.ID }, function(result)
		local data = ConfigManager:GetData("QuestSeason", info.ID)
		UIManager:ShowMessageWithIcon(data.Icon, "Got "..data.Name)
		UIQuestSeason:Refresh()
	end)
end

function UIQuestSeason:GetExtraReward(index)
	if not UIQuestSeason.SeasonItemList then return end
	NetClient:Request("Quest", "CheckSeasonPass", function(hasPass)
		if hasPass then
			local item = UIQuestSeason.SeasonItemList[index]
			local info = AttributeUtil:GetInfo(item)
			NetClient:Request("Quest", "GetExtraReward", { Type = QuestDefine.Type.Season, ID = info.ID }, function(result)
				local data = ConfigManager:GetData("QuestSeasonPremium", info.ID)
				UIManager:ShowMessageWithIcon(data.PremiumIcon, "Got "..data.PremiumName)
				UIQuestSeason:Refresh()
			end)
		else
			UIQuestSeason:Button_Premium()
		end
	end)
end

function UIQuestSeason:Button_BuySeasonPass()
	NetClient:Request("Quest", "CheckSeasonPass", function(hasPass)
		if not hasPass then
			IAPClient:Purchase("SeasonPass", nil, function(success)
				if success then
					UIQuestSeason:Refresh()
				end
			end)	
		else
			UIManager:ShowMessage(Define.Message.HasSeasonPass)
		end
	end)
end

function UIQuestSeason:Skip(index)
	if not UIQuestSeason.SeasonItemList then return end
	local item = UIQuestSeason.SeasonItemList[index]
	local info = AttributeUtil:GetInfo(item)
	IAPClient:Purchase("SkipQuestSeason", nil, function(success)
		if success then
			NetClient:Request("Quest", "SkipNextSeasonQuest", function(result)
				UIQuestSeason:Refresh()
			end)
		end
	end)	
end

function UIQuestSeason:Button_UnlockAll()
	IAPClient:Purchase("UnlockAllSeasonQuest", function(success)
		if success then
			NetClient:Request("Quest", "UnlockAllSeasonQuest", function(result)
				UIQuestSeason:Refresh()
			end)
		end
	end)
end

return UIQuestSeason