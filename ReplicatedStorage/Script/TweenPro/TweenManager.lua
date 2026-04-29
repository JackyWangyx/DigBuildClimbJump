local RunService = game:GetService("RunService")

local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)

local TweenManager = {}

local TweenerCount = 0
local TweenerList = {}

local PlayingTweenerCount = 0
local PlayingTweenerList = {}

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
	for tweenerID, tweener in pairs(PlayingTweenerList) do
		tweener:Update(deltaTime)
	end
end

function TweenManager:GetTweenerList()
	return TweenerList
end

-- Add / Remove

function TweenManager:AddTweener(tweener)
	local success, err = pcall(function()
		if not TweenerList[tweener.ID]  then
			TweenerList[tweener.ID] = tweener
			TweenerCount += 1
		end
	end)
	
	if not success then
		warn(tweener, err)
	end
end

function TweenManager:RemoveTweener(tweener)
	if TweenerList[tweener.ID] then		
		TweenerList[tweener.ID] = nil
		TweenerCount -= 1
	end
end

-- Active / DeActive

function TweenManager:ActiveTweener(tweener)
	if not PlayingTweenerList[tweener.ID]  then
		PlayingTweenerList[tweener.ID] = tweener
		PlayingTweenerCount += 1
	end
end

function TweenManager:DeActiveTweener(tweener)
	if PlayingTweenerList[tweener.ID] then		
		PlayingTweenerList[tweener.ID] = nil
		PlayingTweenerCount -= 1
	end
end

return TweenManager
