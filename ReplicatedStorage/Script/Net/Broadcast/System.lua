local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local EventMananger = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)

local System = {}

-- 接受服务端触发事件，本地执行
function System:DispatchEvent(player, param)
	local evnetName = param.EventName
	local eventParam = param.EventParam
	EventMananger:Dispatch(evnetName, eventParam)
end

function System:ShowMessage(player, param)
	local message = param.Message
	UIManager:ShowMessage(message)
end

function System:OpenUIPage(player, param)
	local name = param.Name
	UIManager:Show(name)
end

return System
