local UINotify = require(game.ReplicatedStorage.ScriptAlias.UINotify)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)
local Define = require(game.ReplicatedStorage.Define)

local NotifyCheckQuestAchievement = {}

function NotifyCheckQuestAchievement:Handle(rootPart)
	if not Define.Quest.Enable then return end
	
	local notifyPart = rootPart:WaitForChild("Notify")
	UINotify:Handle(rootPart, function(notifyPart)
		NetClient:Request("Quest", "CheckNotify", { Type = QuestDefine.Type.Achievement }, function(result)
			notifyPart.Visible = result
		end)
	end
	, UINotify.RefreshType.ListenEvent
	, EventManager.Define.RefreshQuest)
end

return NotifyCheckQuestAchievement
