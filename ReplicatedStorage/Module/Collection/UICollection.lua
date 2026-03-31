local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local AttributeUtil = require(game.ReplicatedStorage.ScriptAlias.AttributeUtil)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local UIListSelect = require(game.ReplicatedStorage.ScriptAlias.UIListSelect)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local UIConfirm = require(game.ReplicatedStorage.ScriptAlias.UIConfirm)
local PetUtil = require(game.ReplicatedStorage.ScriptAlias.PetUtil)
local TweenUtil = require(game.ReplicatedStorage.ScriptAlias.TweenUtil)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local TimeUtil = require(game.ReplicatedStorage.ScriptAlias.TimeUtil)
local TimerManager = require(game.ReplicatedStorage.ScriptAlias.TimerManager)

local Define = require(game.ReplicatedStorage.Define)

local UICollection = {}

UICollection.UIRoot = nil
UICollection.BackFrame = nil
UICollection.ListFrame = nil
UICollection.WorldFrame = nil
UICollection.ItemList = nil

UICollection.SelectWorldIndex = 1

function UICollection:Init(root)
	UICollection.UIRoot = root
	UICollection.BackFrame = Util:GetChildByName(root, "BackFrame")
	UICollection.ListFrame = Util:GetChildByName(root, "ListFrame")
	UICollection.WorldFrame = Util:GetChildByName(root, "WorldFrame")
end

function UICollection:OnShow(param)
	UICollection:SelectWolrd(1)
end

function UICollection:OnHide()

end

function UICollection:Refresh()
	
end

function UICollection:RefreshCollectionList()
	NetClient:Request("Collection", "GetDataList", { Type = "Pet" }, function(infoList)	
		local count = 0
		for index, info in ipairs(infoList) do
			if info.Indexed then
				count += 1
			end		
		end
		
		local info = {
			Value = count,
			Count = #infoList,
		}
		
		UIInfo:SetInfo(UICollection.BackFrame, info)
		
		infoList = Util:ListFindAll(infoList, function(info)
			return info.World == UICollection.SelectWorldIndex
		end)

		UICollection.ItemList = UIList:LoadWithInfo(UICollection.ListFrame, "UICollectionItem", infoList)
		for index, item in ipairs(UICollection.ItemList) do
			local data = infoList[index]
			local image = Util:GetChildByName(item, "Image_Icon")
			if data.Indexed then
				image.ImageColor3 = Color3.new(1, 1, 1)
				count += 1
			else
				image.ImageColor3 = Color3.new(0, 0, 0)
			end		
		end
	end)
end

function UICollection:SelectWolrd(index)
	UICollection.SelectWorldIndex = index
	local info = {
		SelectWorld1 = false,
		SelectWorld2 = false,
		SelectWorld3 = false,
		SelectWorld4 = false,
		SelectWorld5 = false,
	}
	
	for i = 1, 5 do
		local key = "SelectWorld" .. tostring(i)
		info[key] = i == index
	end
	
	UIInfo:SetInfo(UICollection.WorldFrame, info)
	UICollection:RefreshCollectionList()
end

function UICollection:Button_SelectWorld1()
	UICollection:SelectWolrd(1)
end

function UICollection:Button_SelectWorld2()
	UICollection:SelectWolrd(2)
end

function UICollection:Button_SelectWorld3()
	UICollection:SelectWolrd(3)
end

function UICollection:Button_SelectWorld4()
	UICollection:SelectWolrd(4)
end

function UICollection:Button_SelectWorld5()
	UICollection:SelectWolrd(5)
end

function UICollection:Button_SelectWorld6()
	UICollection:SelectWolrd(6)
end

function UICollection:Button_SelectWorld7()
	UICollection:SelectWolrd(7)
end

function UICollection:Button_SelectWorld8()
	UICollection:SelectWolrd(8)
end

function UICollection:Button_SelectWorld9()
	UICollection:SelectWolrd(9)
end

function UICollection:Button_SelectWorld10()
	UICollection:SelectWolrd(10)
end

return UICollection
