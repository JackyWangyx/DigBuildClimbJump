local UINotify = require(game.ReplicatedStorage.ScriptAlias.UINotify)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)

local NotifyCheckCanSignOnline = {}

function NotifyCheckCanSignOnline:Handle(rootPart)
	local notifyPart = rootPart:WaitForChild("Notify")
	local function refresh()
		local uiSignOnlineInfo = UIManager:GetPage("UISignOnline")
		if not uiSignOnlineInfo then
			notifyPart.Visible = false
			return
		end

		local uiSignOnlineScript = uiSignOnlineInfo.Script
		local infoList = uiSignOnlineScript.InfoList
		if not infoList then
			notifyPart.Visible = false
			return
		end

		local result = false
		for _, info in ipairs(infoList) do
			if info.CanGetReward then
				result = true
				break
			end
		end

		notifyPart.Visible = result
	end

	UINotify:Handle(rootPart, function(notifyPart)
		refresh()
	end
	, UINotify.RefreshType.AutoRefresh
	, 1)

	EventManager:Listen(EventManager.Define.RefreshSignOnline, function()
		refresh()
	end)
end

return NotifyCheckCanSignOnline
