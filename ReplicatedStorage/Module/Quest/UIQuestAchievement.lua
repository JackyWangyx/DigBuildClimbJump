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

local UIQuestList = require(game.ReplicatedStorage.ScriptAlias.UIQuestList)
local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)

local Define = require(game.ReplicatedStorage.Define)

UIQuestAchievement = {}

UIQuestAchievement.UIRoot = nil
UIQuestAchievement.ItemList = nil

function UIQuestAchievement:Init(root)
	UIQuestAchievement.UIRoot = root
	UIQuestAchievement.ItemList = nil
end

function UIQuestAchievement:OnShow(param)
	
end

function UIQuestAchievement:OnHide()

end

function UIQuestAchievement:Refresh()
	local itemList = UIQuestList:Refresh(UIQuestAchievement.UIRoot, self, QuestDefine.Type.Achievement, "UIQuestAchievementItem", "UIQuestItem")
	UIQuestAchievement.ItemList = itemList
end

function UIQuestAchievement:GetReward(index)
	if not UIQuestAchievement.ItemList then return end
	local item = UIQuestAchievement.ItemList[index]
	local info = AttributeUtil:GetInfo(item)
	NetClient:Request("Quest", "GetReward", { Type = QuestDefine.Type.Achievement, ID = info.ID }, function(result)
		UIQuestAchievement:Refresh()
	end)
end

function UIQuestAchievement:Skip(index)
	if not UIQuestAchievement.ItemList then return end
	local item = UIQuestAchievement.ItemList[index]
	local info = AttributeUtil:GetInfo(item)
	NetClient:Request("Quest", "Complete", { Type = QuestDefine.Type.Achievement, ID = info.ID }, function(result)
		UIQuestAchievement:Refresh()
	end)
end

return UIQuestAchievement