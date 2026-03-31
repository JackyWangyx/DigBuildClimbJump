local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local ClimbTowerAutoPlay = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerAutoPlay)

local UIClimbTowerAutoPlay = {}

UIClimbTowerAutoPlay.UIRoot = nil

function UIClimbTowerAutoPlay:Init(root)
	UIClimbTowerAutoPlay.UIRoot = root
	UIInfo:HandleAllButton(root, UIClimbTowerAutoPlay)

	UIClimbTowerAutoPlay:Refresh()

	EventManager:Listen(EventManager.Define.RefreshAutoPlay, function(info)
		UIClimbTowerAutoPlay:Refresh()
	end)
end

function UIClimbTowerAutoPlay:Refresh()
	local info = ClimbTowerAutoPlay.Info
	UIInfo:SetInfo(UIClimbTowerAutoPlay.UIRoot, info)
end

-- Auto Game
function UIClimbTowerAutoPlay:Button_AutoGame()
	IAPClient:CheckHasGamePass("AutoPlay", function(isPurchased)
		if isPurchased then
			UIClimbTowerAutoPlay:SwitchAutoPlay()
		else
			IAPClient:Purchase("AutoPlay", function(success)
				if success then
					UIClimbTowerAutoPlay:SwitchAutoPlay()
				end			
			end)
		end
	end)
end

function UIClimbTowerAutoPlay:SwitchAutoPlay()
	local info = ClimbTowerAutoPlay.Info
	if info.IsAutoGame then
		ClimbTowerAutoPlay:EndAutoGame()
	else
		ClimbTowerAutoPlay:StartAutoGame()
	end
end

-- Auto Climb
function UIClimbTowerAutoPlay:Button_AutoClimb()
	local info = ClimbTowerAutoPlay.Info
	if info.IsAutoClimb then
		ClimbTowerAutoPlay:EndAutoClimb()
	else
		ClimbTowerAutoPlay:StartAutoClimb()
	end
end

-- Auto Dig
function UIClimbTowerAutoPlay:Button_AutoDig()
	local info = ClimbTowerAutoPlay.Info
	if info.IsAutoDig then
		ClimbTowerAutoPlay:EndAutoDig()
	else
		ClimbTowerAutoPlay:StartAutoDig()
	end
end

-- Auto Click
function UIClimbTowerAutoPlay:Button_AutoClick()
	local info = ClimbTowerAutoPlay.Info
	if info.IsAutoClick then
		ClimbTowerAutoPlay:EndAutoClick()
	else
		IAPClient:CheckHasGamePass("AutoClick", function(isPurchase)
			if isPurchase then
				if not info.IsAutoClick then
					ClimbTowerAutoPlay:StartAutoClick()
				end
			else
				IAPClient:Purchase("AutoClick", function(success)
					EventManager:Dispatch(EventManager.Define.RefreshAutoPlay, info)
				end)
			end
		end)
	end
end

return UIClimbTowerAutoPlay
