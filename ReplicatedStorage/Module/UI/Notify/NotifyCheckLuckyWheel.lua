local UINotify = require(game.ReplicatedStorage.ScriptAlias.UINotify)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local NotifyCheckLuckyWheel = {}

function NotifyCheckLuckyWheel:Handle(rootPart)
	local notifyPart = rootPart:WaitForChild("Notify")
	UINotify:Handle(rootPart, function(notifyPart)
		NetClient:Request("LuckyWheel", "GetRemainCount", function(result)
			notifyPart.Visible = result > 0
		end)
	end
	, UINotify.RefreshType.ListenEvent
	, EventManager.Define.RefreshLuckyWheel)
end

return NotifyCheckLuckyWheel
