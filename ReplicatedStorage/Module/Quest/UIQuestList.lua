local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local AttributeUtil = require(game.ReplicatedStorage.ScriptAlias.AttributeUtil)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local UIListSelect = require(game.ReplicatedStorage.ScriptAlias.UIListSelect)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local UIConfirm = require(game.ReplicatedStorage.ScriptAlias.UIConfirm)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)

local QuestDeifne = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)

local UIQuestList = {}

function UIQuestList:Refresh(root, listScript, questType, prefabName, itemScriptName)
	local infoList = NetClient:RequestWait("Quest", "GetInfoList", { Type = questType })
	
	local count = #infoList
	if questType == QuestDeifne.Type.Season then
		for index, info in ipairs(infoList) do
			local previewInfo = nil
			if index > 1 then 
				previewInfo = infoList[index - 1]	
				local c1 = previewInfo ~= nil and (previewInfo.State == QuestDeifne.State.Complete or previewInfo.State == QuestDeifne.State.GetReward)
				local c2 = info.State == QuestDeifne.State.Running
				info.CanSkip = c1 and c2
			else
				info.CanSkip = info.State == QuestDeifne.State.Running
			end
		end	
	end
	
	local itemList = UIList:LoadWithInfoData(root, prefabName, infoList, "Quest"..questType)
	UIList:HandleItemList(itemList, listScript, itemScriptName)
	return itemList
end

return UIQuestList
