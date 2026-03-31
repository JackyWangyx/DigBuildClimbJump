local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local AttributeUtil = require(game.ReplicatedStorage.ScriptAlias.AttributeUtil)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local UIToolItem = {}
UIToolItem.__index = UIToolItem

function UIToolItem.new()
	local self = setmetatable({}, UIToolItem)
	return self
end

function UIToolItem:Button_SelectItem(button, param)
	local uiList = param.UIListScript
	local uiRoot = param.UIRoot
	local index = param.Index
	uiList:SelectItem(index)
	
	EventManager:Dispatch(EventManager.Define.SelectTool)
end

return UIToolItem
