local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local UIConditionChecker = {}

UIConditionChecker.Define = require(game.ReplicatedStorage.Define).Condition

function UIConditionChecker:Handle(part, checkerType, requireValue, param, refreshEvent)
	local function RefreshFunc()
		UIConditionChecker:Refresh(part, checkerType, requireValue, param)
	end
	
	RefreshFunc()
	if refreshEvent then
		EventManager:Listen(refreshEvent, function()
			RefreshFunc()
		end)
	end
end

function UIConditionChecker:Refresh(part, checkerType, requireValue, param)
	NetClient:Request("Game", "CheckCondition", {
		Type = checkerType,
		RequireValue = requireValue,
		Param = param
	}, function(result)
		UIInfo:SetInfo(part, result)
	end)
end

return UIConditionChecker
