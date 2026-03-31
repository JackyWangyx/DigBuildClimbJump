local RunService = game:GetService("RunService")

local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)

local TweenManager = {}

local TweenerCount = 0
local TweenerList = {}

if RunService:IsClient() then
	UpdatorManager:RenderStepped(function(deltaTime)
		TweenManager:Update(deltaTime)
	end)
else
	UpdatorManager:Heartbeat(function(deltaTime)
		TweenManager:Update(deltaTime)
	end)
end

function TweenManager:Update(deltaTime)
	for _, tweener in pairs(TweenerList) do
		tweener:Update(deltaTime)
	end
end

function TweenManager:GetTweenerList()
	return TweenerList
end

function TweenManager:AddTweener(tweener)
	if not TweenerList[tweener.ID]  then
		TweenerList[tweener.ID] = tweener
		TweenerCount += 1
	end
end

function TweenManager:RemoveTweener(tweener)
	if TweenerList[tweener.ID] then		
		TweenerList[tweener.ID] = nil
		TweenerCount -= 1
	end
end

return TweenManager
