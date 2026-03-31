local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local AttributeUtil = require(game.ReplicatedStorage.ScriptAlias.AttributeUtil)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)

local UIPartnerItem = {}
UIPartnerItem.__index = UIPartnerItem

function UIPartnerItem.new()
	local self = setmetatable({}, UIPartnerItem)
	return self
end

function UIPartnerItem:Button_SelectItem(button, param)
	local uiList = param.UIListScript
	local uiRoot = param.UIRoot
	local index = param.Index
	uiList:SelectItem(index)
end

return UIPartnerItem
