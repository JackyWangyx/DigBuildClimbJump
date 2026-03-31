local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local TimerManager =require(game.ReplicatedStorage.ScriptAlias.TimerManager)

local UIBuffOnline = {}

UIBuffOnline.Root = nil

function UIBuffOnline:Init(root)
	UIBuffOnline.Root = root
	TimerManager:Interval(1.01, function()
		UIBuffOnline:Refresh()
	end)
end

function UIBuffOnline:Refresh()
	NetClient:Request("BuffOnline", "GetProperty", function(info)
		if info and info.GetPowerFactor3 then
			info.DisplayGetPowerFactor3 = tostring(math.round(info.GetPowerFactor3 * 100)).."%"
			UIInfo:SetInfo(UIBuffOnline.Root, info)
		end
	end)
end

return UIBuffOnline
