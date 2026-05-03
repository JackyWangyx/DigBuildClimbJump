local UINotify = require(game.ReplicatedStorage.ScriptAlias.UINotify)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local NotifyCheckProp = {}

function NotifyCheckProp:Handle(rootPart)
	local notifyPart = rootPart:WaitForChild("Notify")
	UINotify:Handle(rootPart, function(notifyPart)
		NetClient:Request("Prop", "GetPackageList", function(packageList)
			notifyPart.Visible = false
			for _, info in pairs(packageList) do
				if info.Count > 0 then
					notifyPart.Visible = true
					return
				end
			end		
		end)
	end
	, UINotify.RefreshType.ListenEvent
	, EventManager.Define.RefreshProp)
end

return NotifyCheckProp
