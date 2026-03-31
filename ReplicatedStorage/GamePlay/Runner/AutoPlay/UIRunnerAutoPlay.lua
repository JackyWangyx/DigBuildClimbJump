local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local RunnerAutoPlay = require(game.ReplicatedStorage.ScriptAlias.RunnerAutoPlay)

local UIRunnerAutoPlay = {}

UIRunnerAutoPlay.UIRoot = nil

function UIRunnerAutoPlay:Init(root)
	UIRunnerAutoPlay.UIRoot = root
	UIInfo:HandleAllButton(root, UIRunnerAutoPlay)
	
	UIRunnerAutoPlay:Refresh()
	
	EventManager:Listen(EventManager.Define.RefreshAutoPlay, function(info)
		UIRunnerAutoPlay:Refresh()
	end)
end

function UIRunnerAutoPlay:Refresh()
	local info = RunnerAutoPlay:GetInfo()
	UIInfo:SetInfo(UIRunnerAutoPlay.UIRoot, info)
end

-- Game

function UIRunnerAutoPlay:Button_AutoGame()
	local info = RunnerAutoPlay:GetInfo()
	if info.IsAutoGame then
		RunnerAutoPlay:EndAutoGame()
	else
		if not info.IsAutoTraining then
			RunnerAutoPlay:StartAutoGame()
		end
	end
end

-- Training

function UIRunnerAutoPlay:Button_AutoTraining()
	local info = RunnerAutoPlay:GetInfo()
	if info.IsAutoTraining then
		RunnerAutoPlay:EndAutoTraining()
	else
		if not info.IsAutoGame then
			RunnerAutoPlay:StartAutoTraining()
		end
	end
end

-- Click

function UIRunnerAutoPlay:Button_AutoClick()
	local info = RunnerAutoPlay:GetInfo()
	if info.IsAutoClick then
		RunnerAutoPlay:EndAutoClick()
	else
		IAPClient:CheckHasGamePass("AutoClick", function(isPurchase)
			if isPurchase then
				if not info.IsAutoClick then
					RunnerAutoPlay:StartAutoClick()
				end
			else
				IAPClient:Purchase("AutoClick", function(success)
					EventManager:Dispatch(EventManager.Define.RefreshAutoPlay, info)
				end)
			end
		end)
	end
end

return UIRunnerAutoPlay
