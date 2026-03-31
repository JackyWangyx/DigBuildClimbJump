local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local TimerManager = require(game.ReplicatedStorage.ScriptAlias.TimerManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local UIBuffPremium = {}

UIBuffPremium.Root = nil

function UIBuffPremium:Init(root)
	UIBuffPremium.Root = root
	EventManager:Listen(EventManager.Define.RefreshPremium, function()
		UIBuffPremium:Refresh()
	end)
end

function UIBuffPremium:Refresh()
	NetClient:Request("RobloxPremium", "GetProperty", function(info)
		if info and info.MaxSpeedFactor3 then
			info.DisplayMaxSpeedFactor3 = tostring(math.round(info.MaxSpeedFactor3 * 100)).."%"
			UIInfo:SetInfo(UIBuffPremium.Root, info)
		end
	end)
end

return UIBuffPremium
