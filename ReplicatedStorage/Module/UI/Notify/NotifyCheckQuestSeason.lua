local UINotify = require(game.ReplicatedStorage.ScriptAlias.UINotify)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)

local NotifyCheckQuestSeason = {}

function NotifyCheckQuestSeason:Handle(rootPart)
	local notifyPart = rootPart:WaitForChild("Notify")
	UINotify:Handle(rootPart, function(notifyPart)
		NetClient:Request("Quest", "CheckNotify", { Type = QuestDefine.Type.Season }, function(result)
			notifyPart.Visible = result
		end)
	end
	, UINotify.RefreshType.ListenEvent
	, EventManager.Define.RefreshQuest)
end

return NotifyCheckQuestSeason
