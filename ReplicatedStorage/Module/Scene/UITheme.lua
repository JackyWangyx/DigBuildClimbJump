local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local AttributeUtil = require(game.ReplicatedStorage.ScriptAlias.AttributeUtil)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local UIListSelect = require(game.ReplicatedStorage.ScriptAlias.UIListSelect)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local TimerManager = require(game.ReplicatedStorage.ScriptAlias.TimerManager)
local TimeUtil = require(game.ReplicatedStorage.ScriptAlias.TimeUtil)

local Define = require(game.ReplicatedStorage.Define)

local UITheme = {}

UITheme.UIRoot = nil
UITheme.InfoFrame = nil
UITheme.ThemeFrame = nil

UITheme.ItemList = nil
UITheme.InfoList = nil

UITheme.SelectIndex = -1
UITheme.CurrentThemeKey = nil
UITheme.CurrentThemeInfo = nil
UITheme.HandleButtonList = false

function UITheme:Init(root)
	UITheme.UIRoot = root
	UITheme.InfoFrame = Util:GetChildByName(root, "ThemeInfo")
	UITheme.ThemeFrame = Util:GetChildByName(root, "ThemeList")
end

function UITheme:OnShow(param)
	UITheme.ItemList = nil
	UITheme.SelectIndex = -1
end

function UITheme:OnHide()

end

function UITheme:Refresh()
	UITheme.CurrentThemeKey = NetClient:RequestWait("Theme", "GetCurrentTheme")	
	NetClient:Request("Theme", "GetInfoList", function(infoList)
		for index, info in ipairs(infoList) do
			local data = ConfigManager:GetData("Theme", info.ID)
			info = Util:TableMerge(info, data)
			
		
			local isCurrent = UITheme.CurrentThemeKey == info.ThemeKey
			if isCurrent and UITheme.SelectIndex < 0 then
				UITheme.SelectIndex = index
			end
			
			local isSelect = UITheme.SelectIndex == index
			info.IsSelect = isSelect
			
			if isSelect then
				UITheme.SelectThemeInfo = info
			end
		end
		
		UITheme.InfoList = infoList
		UITheme.ItemList = UIList:LoadWithInfo(UITheme.ThemeFrame, "UIThemeItem", infoList)
		--UIList:HandleItemList(UITheme.ItemList, UITheme, "UIThemeItem")
		if not UITheme.HandleButtonList then
			UITheme.HandleButtonList = true
			UIList:HandleItemList(UITheme.ItemList, UITheme, "UIThemeItem")
		end
		
		UITheme:RefreshInfo()
	end)
end

function UITheme:RefreshInfo()
	if not UITheme.SelectThemeInfo then
		return
	end
	
	local info = {
		IsCurrent = UITheme.SelectThemeInfo.ThemeKey == UITheme.CurrentThemeKey,
	}
	
	Util:TableMerge(info, UITheme.SelectThemeInfo)
	UIInfo:SetInfo(UITheme.InfoFrame, info)
end

function UITheme:SelectItem(index)
	if not UITheme.ItemList then return end
	UITheme.SelectIndex = index
	UITheme:Refresh()
end

function UITheme:Button_Switch()
	if not UITheme.ItemList then return end
	local themeKey = UITheme.SelectThemeInfo.ThemeKey
	NetClient:Request("Theme", "SwitchTheme", { ThemeKey = themeKey }, function(result)
		UITheme:Refresh()
	end)
end

function UITheme:Button_Buy()
	if not UITheme.ItemList then return end
	local themeKey = UITheme.SelectThemeInfo.ThemeKey
	NetClient:Request("Theme", "UnlockTheme", { ThemeKey = themeKey }, function(result)
		if result.Success then
			UITheme:Refresh()
		else
			UIManager:ShowMessage(result.Message)
		end		
	end)
end

return UITheme
