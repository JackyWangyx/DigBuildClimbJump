local UINotify = require(game.ReplicatedStorage.ScriptAlias.UINotify)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local TimerManager = require(game.ReplicatedStorage.ScriptAlias.TimerManager)
local TimeUtil = require(game.ReplicatedStorage.ScriptAlias.TimeUtil)

local NotifyCheckCanSignDaily30 = {}

function NotifyCheckCanSignDaily30:Handle(rootPart)
	local notifyPart = rootPart:WaitForChild("Notify")
	local function refresh()
		NetClient:Request("Sign", "CheckCanSignDaily", { Key = "SignDaily30" } , function(result)
			notifyPart.Visible = result
		end)
	end
	
	refresh()
	
	TimerManager:After(TimeUtil:SecondsToNextDay() + 1, function()
		UINotify:Handle(rootPart, function(notifyPart)
			refresh()
		end
		, UINotify.RefreshType.AutoRefresh
		, 60 * 60 * 24)
	end)
	
	EventManager:Listen(EventManager.Define.RefreshSignOnline, function()
		refresh()
	end)
end

return NotifyCheckCanSignDaily30
