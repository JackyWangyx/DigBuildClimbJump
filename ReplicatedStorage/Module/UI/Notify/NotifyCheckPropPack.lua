local UINotify = require(game.ReplicatedStorage.ScriptAlias.UINotify)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local NotifyCheckPropPack = {}

function NotifyCheckPropPack:Handle(rootPart)
	local notifyPart = rootPart:WaitForChild("Notify")
	UINotify:Handle(rootPart, function(notifyPart)
		NetClient:Request("Prop", "CheckHasPackage", function(result)
			notifyPart.Visible = result
		end)
	end
	, UINotify.RefreshType.ListenEvent
	, EventManager.Define.RefreshProp)
end

return NotifyCheckPropPack
