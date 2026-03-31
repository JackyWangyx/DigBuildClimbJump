local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local AttributeUtil = require(game.ReplicatedStorage.ScriptAlias.AttributeUtil)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local UIListSelect = require(game.ReplicatedStorage.ScriptAlias.UIListSelect)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local UIConfirm = require(game.ReplicatedStorage.ScriptAlias.UIConfirm)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)

local AnimalUtil = require(game.ReplicatedStorage.ScriptAlias.AnimalUtil)

local Define = require(game.ReplicatedStorage.Define)

local UIAnimalEquip = {}

UIAnimalEquip.UIRoot = nil
UIAnimalEquip.UIAnimalEquipFrame = nil
--UIAnimalEquip.ButtonAnimalStore = nil
UIAnimalEquip.InfoList = nil
UIAnimalEquip.ItemList = nil

function UIAnimalEquip:Init(root)
	UIAnimalEquip.UIRoot = root
	UIAnimalEquip.UIAnimalEquipFrame = Util:GetChildByName(root, "UIAnimalEquip")
	UIAnimalEquip.ButtonToolStore = Util:GetChildByName(UIAnimalEquip.UIAnimalEquipFrame, "Button_ToolStore")
	
	EventManager:Listen(EventManager.Define.RefreshAnimal, function()
		UIAnimalEquip:RefreshEquip()
	end)
	
	EventManager:Listen(EventManager.Define.RefreshTool, function()
		UIAnimalEquip:Refresh()
	end)
	
	UIAnimalEquip:Refresh()
end

function UIAnimalEquip:Refresh()
	UIAnimalEquip:RefreshEquip()
	UIAnimalEquip:RefreshTool()
end

function UIAnimalEquip:RefreshEquip()
	NetClient:RequestQueue({
		{ Module = "Animal", Action = "GetEquipList" },
		{ Module = "Animal", Action = "GetEquipMax" },
	}, function(result)
		local infoList = result[1]
		for _, info in ipairs(infoList) do
			AnimalUtil:ProcessAnimalInfo(info)
		end

		infoList = AnimalUtil:Sort(infoList)
		
		local equipMax = result[2]
		for i = #infoList + 1, equipMax do
			table.insert(infoList, {
				IsEquip = false
			})
		end

		UIAnimalEquip.InfoList = infoList
		UIAnimalEquip.ItemList = UIList:LoadWithInfoData(UIAnimalEquip.UIAnimalEquipFrame, "UIAnimalEquipItem", infoList, "Animal")
		UIList:HandleItemList(UIAnimalEquip.ItemList, UIAnimalEquip, "UIAnimalEquipItem")
	end)
end

function UIAnimalEquip:RefreshTool()
	NetClient:Request("Tool", "GetEquip", function(info)
		local toolData = ConfigManager:GetData("Tool", info.ID)
		UIInfo:SetInfo(UIAnimalEquip.ButtonToolStore, toolData)
	end)
end

function UIAnimalEquip:SelectItem(index)
	UIManager:ShowAndHideOther("AnimalPack")
end

return UIAnimalEquip
