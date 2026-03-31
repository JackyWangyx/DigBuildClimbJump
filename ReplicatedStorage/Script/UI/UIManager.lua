local StarterGui = game.StarterGui

local TweenUtil = require(game.ReplicatedStorage.ScriptAlias.TweenUtil)
local UTween = require(game.ReplicatedStorage.ScriptAlias.UTween)
local StackList = require(game.ReplicatedStorage.ScriptAlias.StackList)
local ResourcesManager = require(game.ReplicatedStorage.ScriptAlias.ResourcesManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local UIAnimation = require(game.ReplicatedStorage.ScriptAlias.UIAnimation)
local UIEffect = require(game.ReplicatedStorage.ScriptAlias.UIEffect)
local UIPage = nil

local UIManager = {}

UIManager.PlayerGUI = nil

UIManager.AnimationType = {
	None = "None",
	Default = "Default",
	Zoom = "Scale",
	Fade = "Fade",
	Slide = "Slide",
}

UIManager.GroupType = {
	Page = 1,
	Cover = 2,
	Top = 3,
}

UIManager.GroupCache = {}
UIManager.Enable = true

---------------------------------------
-- UI Script Param

local uiScriptDemo = {
	CheckExclusiveFunc = false, 							-- 排除显示控制之外
	ShowAnimationType = UIManager.AnimationType.Default,
	HideAnimationType = UIManager.AnimationType.Default,
}

---------------------------------------

-- UI Folder
local UIPageFolder = game.ReplicatedStorage.Prefab.UIPage
local UIDialogFolder = game.ReplicatedStorage.Prefab.UIDialog
local UIItemFolder = game.ReplicatedStorage.Prefab.UIItem
local UICoverFolder = game.ReplicatedStorage.Prefab.UICover

-- Runtime
local UIInfoList = {}

-- ==============================
-- Init
-- ==============================
function UIManager:Init()
	UIPage = require(game.ReplicatedStorage.ScriptAlias.UIPage)
	local player = game.Players.LocalPlayer
	player.CharacterAdded:Connect(function()
		UIManager.PlayerGUI = game.Players.LocalPlayer:WaitForChild("PlayerGui")
		UIManager:InitImpl()
	end)
	
	UIManager.PlayerGUI = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	UIEffect:Init()
	UIManager:InitImpl()
end

function UIManager:InitImpl()
	local function CreateUIFolder(name)
		local floder = Instance.new("Folder")
		floder.Name = name
		floder.Parent = UIManager.PlayerGUI
		return floder
	end

	local showFolder = CreateUIFolder("Show")
	local hideFolder = CreateUIFolder("Hide")
	local coverFolder = CreateUIFolder("Cover")
	local topFolder = CreateUIFolder("Top")
	
	UIManager.GroupCache = {}
	UIManager.GroupCache[UIManager.GroupType.Page] = {
		ShowFolder = showFolder,
		HideFolder = hideFolder,
		Stack = StackList.new(),
		DisplayOrder = 0,
	}
	
	UIManager.GroupCache[UIManager.GroupType.Cover] = {
		ShowFolder = coverFolder,
		HideFolder = hideFolder,
		Stack = StackList.new(),
		DisplayOrder = 1000,
	}
	
	UIManager.GroupCache[UIManager.GroupType.Top] = {
		ShowFolder = topFolder,
		HideFolder = hideFolder,
		Stack = StackList.new(),
		DisplayOrder = 2000,
	}
	
	UIInfoList = {}
	local function initFolderPages(folder)
		for _, uiPrefab in ipairs(folder:GetChildren()) do
			if uiPrefab:IsA("ScreenGui") then
				local success, msg = pcall(function()
					UIManager:InitPage(uiPrefab)
				end)

				if not success then
					warn("[UIManager] Init Fail : ", uiPrefab.Name, debug.traceback(msg, 2))
				end
			end
		end
	end

	initFolderPages(UIPageFolder)
	initFolderPages(UICoverFolder)

	UIManager:HideAll()

	task.wait()
	UIManager:Show("UIMain")
	task.wait()
	UIManager:Cover("UIMessage")
end

function UIManager:InitPage(pagePrefab)
	local pageInstance = pagePrefab:Clone()
	pageInstance.Parent = UIManager.PlayerGUI
	pageInstance.Enabled = false
	
	local uiInfo = {
		Name = pageInstance.Name,
		UI = pageInstance,
		MainFrame = pageInstance:FindFirstChild("MainFrame"),
		EnableAnimation = true,
	}

	local uiScriptFile = Util:GetChildByTypeAndName(
		game.ReplicatedStorage, 
		"ModuleScript", 
		uiInfo.Name, 
		true 
	)
	
	if uiScriptFile then
		local uiScript = require(uiScriptFile)
		uiInfo.Script = uiScript
		uiInfo.InitFunc = uiScript.Init
		uiInfo.ShowFunc = uiScript.OnShow
		uiInfo.HideFunc = uiScript.OnHide
		uiInfo.RefreshFunc = uiScript.Refresh
		uiInfo.CheckExclusiveFunc = uiScript.CheckExclusive		-- 排除显示控制
		
		UIAnimation:HandlePageShow(uiInfo, uiScript.ShowAnimationType)
		UIAnimation:HandlePageHide(uiInfo, uiScript.HideAnimationType)
		
		local childList = uiInfo.UI:GetDescendants()
		UIPage:Handle(uiInfo.UI, uiScript, childList)

		if uiInfo.InitFunc then
			task.spawn(function()
				uiInfo.InitFunc(uiScript, uiInfo.UI)
			end)
		end
	end
	
	UIEffect:HanldeUIInfo(uiInfo)
	UIInfoList[uiInfo.Name] = uiInfo
end

-- ==============================
-- Show / Hide Page
-- ==============================
function UIManager:Show(uiName, param)
	if not UIManager.Enable then return end
	UIManager:ShowPageImpl(uiName, UIManager.GroupType.Page, param)
end

function UIManager:Cover(uiName, param)
	if not UIManager.Enable then return end
	UIManager:ShowPageImpl(uiName, UIManager.GroupType.Cover, param)
end

function UIManager:ShowAndHideOther(uiName, param)
	if not UIManager.Enable then return end
	uiName = UIManager:GetUIKey(uiName)
	local currentUI = UIManager:GetCurrentPage()

	if currentUI and currentUI.Name ~= uiName and currentUI.Name ~= "UIMain" then
		UIManager:Hide(currentUI.Name, false)
	end

	UIManager:Show(uiName, param)
end

function UIManager:ShowPageImpl(uiName, uiGroupType, param)
	if not UIManager.Enable then return end
	local uiGroup = UIManager:GetGroup(uiGroupType)
	local uiStack = uiGroup.Stack
	uiName = UIManager:GetUIKey(uiName)
	local uiInfo = UIInfoList[uiName]
	if not uiInfo or uiStack:Exist(uiName) then return end

	local currentUI = UIManager:GetCurrentPage()

	uiStack:Push(uiName, uiInfo)
	local mainFrame = uiInfo.MainFrame
	uiInfo.UI.Enabled = true
	uiInfo.UI.Parent = uiGroup.ShowFolder
	uiInfo.UI.DisplayOrder = uiStack:Count() + uiGroup.DisplayOrder

	local exclusive = currentUI and currentUI.CheckExclusiveFunc and currentUI.CheckExclusiveFunc()
	if not exclusive then
		if uiInfo.ShowAnimationType ~= "None" then
			if uiInfo.HideTweener then
				for _, tweener in ipairs(uiInfo.HideTweener) do
					if tweener:IsPlaying() then tweener:Stop() end
				end
			end

			for _, tweener in ipairs(uiInfo.ShowTweener) do
				if tweener:IsPlaying() then tweener:Stop() end
				tweener:Play()
			end
		else
			UIManager:SetMaxSize(mainFrame)
		end

		if uiInfo.ShowFunc then
			local success, msg = pcall(function()
				uiInfo.ShowFunc(uiInfo.Script, param)
			end)

			if not success then
				warn("[UIManager] Show Fail : ", uiName, debug.traceback(msg, 2))
			end
		end

		if uiInfo.RefreshFunc then
			task.spawn(function()
				local success, msg = pcall(function()
					uiInfo.RefreshFunc(uiInfo.Script, param)
				end)

				if not success then
					warn("[UIManager] Refresh Fail : ", uiName, debug.traceback(msg, 2))
				end
			end)
		end
	end

	UIAnimation:RefreshBlur(self)
	
	EventManager:Dispatch(EventManager.Define.ShowUI, uiName)
end

function UIManager:Hide(uiName, processBlur)
	if not UIManager.Enable then return end
	uiName = UIManager:GetUIKey(uiName)
	local uiInfo = UIInfoList[uiName]
	if not uiInfo then return end
	
	local uiStack = nil
	local uiGroup
	local page = UIManager:GetCurrentPage()
	if page.Name == uiInfo.Name then
		uiGroup = UIManager:GetGroup(UIManager.GroupType.Page)
		uiStack = uiGroup.Stack
	else
		local cover = UIManager:GetCurrentCover()
		if cover.Name == uiInfo.Name then
			uiGroup = UIManager:GetGroup(UIManager.GroupType.Cover)
			uiStack = uiGroup.Stack
		else
			return
		end		
	end
	
	local uiInstance = uiInfo.UI
	local mainFrame = uiInfo.MainFrame
	
	if uiStack then
		uiStack:Pop()	
		uiInstance.Parent = uiGroup.HideFolder
	end
	
	if uiInfo.HideAnimationType ~= "None" then
		if uiInfo.ShowTweener then
			for _, tweener in ipairs(uiInfo.ShowTweener) do
				if tweener:IsPlaying() then tweener:Stop() end
			end
		end

		for _, tweener in ipairs(uiInfo.HideTweener) do
			if tweener:IsPlaying() then tweener:Stop() end
			tweener:Play()
		end
	else
		uiInstance.Enabled = false
	end

	if uiInfo.HideFunc then
		local success, msg = pcall(function()
			uiInfo.HideFunc()
		end)

		if not success then
			warn("[UIManager] Hide Fail : ", uiName, debug.traceback(msg, 2))
		end
	end
	
	if processBlur == nil then processBlur = true end
	if processBlur then
		UIAnimation:RefreshBlur(self)
	else
		task.delay(0.35, function()
			UIAnimation:RefreshBlur(self)
		end)
	end	
	
	EventManager:Dispatch(EventManager.Define.HideUI, uiName)
end

-- ==============================
-- Dialog
-- ==============================

function UIManager:ShowDialog(uiName, param)
	if not UIManager.Enable then return end
	local uiGroup = UIManager:GetGroup(UIManager.GroupType.Top)
	local uiStack = uiGroup.Stack
	local uiInstance = UIDialogFolder:WaitForChild(UIManager:GetUIKey(uiName))
	local mainFrame = uiInstance.MainFrame
	uiInstance.Enabled = true
	uiInstance.Parent = uiGroup.ShowFolder
	uiInstance.DisplayOrder = uiStack:Count() + uiGroup.DisplayOrder
	
	UIAnimation:ShowDialog(mainFrame)
	UIAnimation:RefreshBlur(self)
	return uiInstance
end

function UIManager:HideDialog(uiInstance)
	if not UIManager.Enable then return end
	local uiGroup = UIManager:GetGroup(UIManager.GroupType.Top)
	local uiStack = uiGroup.Stack
	local mainFrame = uiInstance.MainFrame
	UIAnimation:HideDialog(mainFrame,  function()
		uiInstance.Enabled = false
		uiInstance.Parent = UIDialogFolder
	end)
	
	UIAnimation:RefreshBlur(self)
end

-- ==============================
-- Message
-- ==============================
function UIManager:ShowMessage(message)
	local uiMessageInfo = UIManager:GetPage("UIMessage")
	if uiMessageInfo and uiMessageInfo.Script then
		uiMessageInfo.Script:ShowMessage(message)
	end
end

function UIManager:ShowMessageWithIcon(icon, message)
	local uiMessageInfo = UIManager:GetPage("UIMessage")
	if uiMessageInfo and uiMessageInfo.Script then
		uiMessageInfo.Script:ShowMessageWithIcon(icon, message)
	end
end

-- ==============================
-- Misc
-- ==============================
function UIManager:SetMaxSize(part)
	part.Size = UDim2.new(1, 0, 1, 0)
	part.AnchorPoint = Vector2.new(0.5, 0.5)
	part.Position = UDim2.new(0.5, 0, 0.5, 0)
end

function UIManager:SetMinSize(part)
	part.Size = UDim2.new(0, 0, 0, 0)
end

-- ==============================
-- Get Info
-- ==============================

function UIManager:GetUIKey(uiName)
	if not Util:IsStrStartWith(uiName, "UI") then
		return "UI" .. uiName
	else
		return uiName
	end
end

function UIManager:GetCurrentPage()
	local uiGroup = UIManager:GetGroup(UIManager.GroupType.Page)
	local stack = uiGroup.Stack
	local top = stack:Top()
	return top and top.Value or nil
end

function UIManager:GetCurrentCover()
	local uiGroup = UIManager:GetGroup(UIManager.GroupType.Cover)
	local stack = uiGroup.Stack
	local top = stack:Top()
	return top and top.Value or nil
end

function UIManager:GetGroup(groupType)
	return UIManager.GroupCache[groupType]
end

function UIManager:GetPage(uiName)
	return UIInfoList[UIManager:GetUIKey(uiName)]
end

function UIManager:ContainsPage(uiName)
	local uiGroup = UIManager:GetGroup(UIManager.GroupType.Page)
	local uiStack = uiGroup.Stack
	local uiName = UIManager:GetUIKey(uiName)
	return uiStack:Exist(uiName)
end

function UIManager:ContainsCover(uiName)
	local uiGroup = UIManager:GetGroup(UIManager.GroupType.Cover)
	local uiStack = uiGroup.Stack
	local uiName = UIManager:GetUIKey(uiName)
	return uiStack:Exist(uiName)
end

function UIManager:HideAll()
	local uiGroup = UIManager:GetGroup(UIManager.GroupType.Page)
	local uiStack = uiGroup.Stack
	for _, uiInfo in pairs(UIInfoList) do
		uiInfo.UI.Enabled = false
		uiInfo.UI.Parent = uiGroup.HideFolder
	end
	
	uiStack:Clear()
end

return UIManager
