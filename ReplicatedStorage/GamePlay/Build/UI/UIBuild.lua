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
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local BuildManager = require(game.ReplicatedStorage.ScriptAlias.BuildManager)
local BuildUtil = require(game.ReplicatedStorage.ScriptAlias.BuildUtil)
local BuildDefine = require(game.ReplicatedStorage.ScriptAlias.BuildDefine)

local Define = require(game.ReplicatedStorage.Define)

local UIBuild = {}

UIBuild.UIRoot = nil
UIBuild.EditFrame = nil
UIBuild.DeleteFrame = nil

UIBuild.ItemList = nil
UIBuild.SelectIndex = 0

function UIBuild:Init(root)
	UIBuild.UIRoot = root
	
	UIBuild.EditFrame = root.MainFrame.EditFrame
	UIBuild.DeleteFrame = root.MainFrame.DeleteFrame
	
	EventManager:Listen(EventManager.Define.BuildStart, function()
		
	end)
	
	EventManager:Listen(EventManager.Define.BuildEnd, function()

	end)
	
	EventManager:Listen(EventManager.Define.SwitchBuildPhase, function()
		UIBuild:RefreshPhase()
	end)
	
	EventManager:Listen(EventManager.Define.RefreshBuildPartList, function()
		UIBuild:RefreshPartList()
	end)
end

function UIBuild:OnShow(param)
	UIBuild.SelectIndex = 1
end

function UIBuild:OnHide()
	
end

function UIBuild:Refresh()
	UIBuild:RefreshPhase()
	
	if UIBuild.EditFrame.Visible then
		UIBuild:RefreshPartList()
	end
end

function UIBuild:RefreshPhase()
	UIBuild.EditFrame.Visible = BuildManager.Phase == BuildDefine.BuildPhase.Edit
	UIBuild.DeleteFrame.Visible = BuildManager.Phase == BuildDefine.BuildPhase.Remove
end

function UIBuild:RefreshPartList()
	local infoList = NetClient:RequestWait("Build", "GetPackagePartList")
	infoList = BuildUtil:ProcessPartList(infoList)
	UIBuild.ItemList = UIList:LoadWithInfoData(UIBuild.EditFrame, "UIBuildPartItem", infoList, "BuildPart")	
	UIList:HandleItemList(UIBuild.ItemList, UIBuild, "UIBuildPartItem")
	UIListSelect:HandleSelectOne(UIBuild.ItemList)
	
	if UIBuild.SelectIndex > #UIBuild.ItemList then
		UIBuild.SelectIndex = 0
	end
	
	UIBuild:SelectItem(UIBuild.SelectIndex)
	if UIBuild.SelectIndex > 0 then
		local selectItem = UIBuild.ItemList[UIBuild.SelectIndex]
		UIListSelect:SetSelect(selectItem, true)
	end
end

function UIBuild:SelectItem(index)
	if not UIBuild.ItemList or #UIBuild.ItemList == 0 then
		BuildManager:SelectPart(nil)
		return
	end
	
	UIBuild.SelectIndex = index
	if UIBuild.SelectIndex > #UIBuild.ItemList then
		UIBuild.SelectIndex = #UIBuild.ItemList
	end
	
	local selectItem = UIBuild.ItemList[UIBuild.SelectIndex]
	local partData = AttributeUtil:GetData(selectItem)
	BuildManager:SelectPart(partData)
end

function UIBuild:Button_Remove()
	if not UIBuild.ItemList then return end
	if BuildManager.Phase == BuildDefine.BuildPhase.Edit then
		BuildManager:SetPhase(BuildDefine.BuildPhase.Remove)
	elseif BuildManager.Phase == BuildDefine.BuildPhase.Remove then
		BuildManager:SetPhase(BuildDefine.BuildPhase.Edit)
	end
end

function UIBuild:Button_Rotate()
	if not UIBuild.ItemList then return end
	BuildManager:RotatePart()
end

function UIBuild:Button_Complete()
	
end

return UIBuild
