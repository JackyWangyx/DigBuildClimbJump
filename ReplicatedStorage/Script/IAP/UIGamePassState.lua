local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local UIGamePassState = {}

UIGamePassState.Root = nil
UIGamePassState.List = {}

function UIGamePassState:Init(root)
	UIGamePassState.Root = root.ScrollingFrame
	local partList = UIGamePassState.Root:GetChildren()
	for _, child in pairs(partList) do
		local name = child.Name
		local prefix = "GamePass_"
		if string.sub(name, 1, #prefix) == prefix then
			local suffix = string.sub(name, #prefix + 1)
			local info = {
				Part = child,
				Name = suffix,
			}
			
			table.insert(UIGamePassState.List, info)
		end
	end
	
	task.wait()
	EventManager:Listen(EventManager.Define.RefreshGamePass, function()
		UIGamePassState:Refresh()
	end)
	
	UIGamePassState:Refresh()
end

function UIGamePassState:Refresh()
	for _, info in pairs(UIGamePassState.List) do
		task.wait(0.1)
		IAPClient:CheckHasGamePass(info.Name, function(result)
			info.Part.Visible = result
		end)
	end
end

return UIGamePassState
