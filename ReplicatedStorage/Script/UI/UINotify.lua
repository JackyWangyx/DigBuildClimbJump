local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local UIEffect = require(game.ReplicatedStorage.ScriptAlias.UIEffect)

local UINotify = {}

UINotify.RefreshType = {
	AutoRefresh = 1,
	ListenEvent = 2,
}

function UINotify:Handle(targetPart, checker, refreshType, refreshParam)
	if not checker then return end
	local notifyPart = targetPart:FindFirstChild("Notify")
	if not notifyPart then
		return
	end
	
	notifyPart.Visible = false
	if refreshType == UINotify.RefreshType.AutoRefresh then
		local refreshTime = refreshParam or 1
		local lastRefreshTime = tick()
		UpdatorManager:Heartbeat(function(deltaTime)
			local currentTime = tick()
			if currentTime - lastRefreshTime > refreshTime then
				checker(notifyPart)
				--notifyPart.Visible = show
				lastRefreshTime = currentTime
			end
		end)
	elseif refreshType == UINotify.RefreshType.ListenEvent then
		local eventName = refreshParam
		EventManager:Listen(eventName, function()
			checker(notifyPart)
		end)
	end
	
	task.spawn(function()
		task.wait(1)
		checker(notifyPart)
	end)
end

return UINotify
