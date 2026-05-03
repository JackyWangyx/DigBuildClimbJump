local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local ObjectInfo = require(game.ReplicatedStorage.ScriptAlias.ObjectInfo)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)

local UITradePlayerItem = {}
UITradePlayerItem.__index = UITradePlayerItem

function UITradePlayerItem.new()
	local self = setmetatable({}, UITradePlayerItem)
	return self
end

function UITradePlayerItem:Button_Invite(button, param)
	local uiList = param.UIListScript
	local uiRoot = param.UIRoot
	local index = param.Index
	uiList:Select(index)
end

return UITradePlayerItem