local UINotify = require(game.ReplicatedStorage.ScriptAlias.UINotify)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local NotifyRebirth = {}

function NotifyRebirth:Handle(rootPart)
	local notifyPart = rootPart:WaitForChild("Notify")
	UINotify:Handle(rootPart, function(notifyPart)
		NetClient:Request("Rebirth", "CheckCanRebirth", function(result)
			notifyPart.Visible = result
		end)
	end
	, UINotify.RefreshType.ListenEvent
	, EventManager.Define.RefreshRebirth)
end

return NotifyRebirth
