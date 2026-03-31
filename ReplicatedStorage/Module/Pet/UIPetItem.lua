local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local AttributeUtil = require(game.ReplicatedStorage.ScriptAlias.AttributeUtil)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)

local UIPetItem = {}

UIPetItem.__index = UIPetItem

function UIPetItem.new()
	local self = setmetatable({}, UIPetItem)
	return self
end

function UIPetItem:Button_SelectItem(button, param)
	local uiList = param.UIListScript
	local uiRoot = param.UIRoot
	local index = param.Index
	uiList:SelectItem(index)
end

function UIPetItem:Button_Lock(button, param)
	local uiList = param.UIListScript
	local uiRoot = param.UIRoot
	local index = param.Index
	local instanceID = AttributeUtil:GetInfoValue(uiRoot, "InstanceID")
	NetClient:Request("Pet", "Lock", { InstanceID = instanceID }, function(result)
		if result  then
			AttributeUtil:SetInfoValue(uiRoot, "IsLock", true)
			UIInfo:SetValue(uiRoot, "IsLock", true)
			uiList:RefreshInfo()
		end
	end)
end

function UIPetItem:Button_UnLock(button, param)
	local uiList = param.UIListScript
	local uiRoot = param.UIRoot
	local index = param.Index
	local instanceID = AttributeUtil:GetInfoValue(uiRoot, "InstanceID")
	NetClient:Request("Pet", "UnLock", { InstanceID = instanceID }, function(result)
		if result  then
			AttributeUtil:SetInfoValue(uiRoot, "IsLock", false)
			UIInfo:SetValue(uiRoot, "IsLock", false)
			uiList:RefreshInfo()
		end
	end)
end

return UIPetItem
