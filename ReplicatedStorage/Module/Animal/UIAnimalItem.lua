local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local ObjectInfo = require(game.ReplicatedStorage.ScriptAlias.ObjectInfo)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)

local UIAnimalItem = {}

UIAnimalItem.__index = UIAnimalItem

function UIAnimalItem.new()
	local self = setmetatable({}, UIAnimalItem)
	return self
end

function UIAnimalItem:Button_SelectItem(button, param)
	local uiList = param.UIListScript
	local uiRoot = param.UIRoot
	local index = param.Index
	uiList:SelectItem(index)
end

function UIAnimalItem:Button_Lock(button, param)
	local uiList = param.UIListScript
	local uiRoot = param.UIRoot
	local index = param.Index
	local instanceID = ObjectInfo:GetInfoValue(uiRoot, "InstanceID")
	NetClient:Request("Animal", "Lock", { InstanceID = instanceID }, function(result)
		if result  then
			ObjectInfo:SetInfoValue(uiRoot, "IsLock", true)
			UIInfo:SetValue(uiRoot, "IsLock", true)
			uiList:RefreshInfo()
		end
	end)
end

function UIAnimalItem:Button_UnLock(button, param)
	local uiList = param.UIListScript
	local uiRoot = param.UIRoot
	local index = param.Index
	local instanceID = ObjectInfo:GetInfoValue(uiRoot, "InstanceID")
	NetClient:Request("Animal", "UnLock", { InstanceID = instanceID }, function(result)
		if result  then
			ObjectInfo:SetInfoValue(uiRoot, "IsLock", false)
			UIInfo:SetValue(uiRoot, "IsLock", false)
			uiList:RefreshInfo()
		end
	end)
end

return UIAnimalItem
