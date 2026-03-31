local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local DebugCommandsTab = require(script.Parent.Tab.DebugCommandsTab)
local DebugLogTab = require(script.Parent.Tab.DebugLogTab)
local DebugBrowserTab = require(script.Parent.Tab.DebugBrowserTab)
local PerformanceUtil = require(script.Parent.PerformanceUtil)

local Define = require(game.ReplicatedStorage.Define)

local DebugWindow = {}

function DebugWindow:CreateWindow()
	local player = game.Players.LocalPlayer
	local gui = Instance.new("ScreenGui")
	gui.Name = "DebugWindow"
	gui.Enabled = false
	gui.Parent = player:WaitForChild("PlayerGui")
	gui.DisplayOrder = 999999

	-- 主容器
	local container = Instance.new("Frame")
	container.Name = "MainFrame"
	container.Size = UDim2.new(0.65, 0, 0.7, 0)
	container.Position = UDim2.new(0.5, 0, 0.5, 0)
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	container.BackgroundTransparency = 0.05
	container.Parent = gui
	Instance.new("UICorner", container).CornerRadius = UDim.new(0, 12)

	DebugWindow:CreateTitleBar(container)
	DebugWindow:CreateTabBar(container)
	
	return gui
end

function DebugWindow:CreateTitleBar(container)
	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 40)
	titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	titleBar.Parent = container
	Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Text = "🔧 <b>Debug Tools</b>   <i>Ver : "..Define.Version .."</i>"
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 20
	titleLabel.TextColor3 = Color3.new(1,1,1)
	titleLabel.RichText = true
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(0.4, 0, 1, 0)
	titleLabel.Position = UDim2.new(0, 10, 0, 0)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = titleBar

	local fpsLabel = Instance.new("TextLabel")
	fpsLabel.Size = UDim2.new(0.2, -10, 1, 0)
	fpsLabel.Position = UDim2.new(0.8, 0, 0, 0)
	fpsLabel.BackgroundTransparency = 1
	fpsLabel.Text = "FPS: 0.0"
	fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
	fpsLabel.Font = Enum.Font.GothamBold
	fpsLabel.TextSize = 18
	fpsLabel.TextXAlignment = Enum.TextXAlignment.Right
	fpsLabel.Parent = titleBar

	UpdatorManager:Heartbeat(function()
		local fps = PerformanceUtil:GetFPS()
		fpsLabel.Text = string.format("FPS: %.1f", fps)
	end)
end

local TabList = {}
local ActiveTab = nil

function DebugWindow:CreateTabBar(container)
	local tabBar = Instance.new("Frame")
	tabBar.Size = UDim2.new(0, 10, 0, 40)
	tabBar.Position = UDim2.new(0, 10, 0, 40)
	tabBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	tabBar.Parent = container
	
	-- 按钮布局
	local tabList = Instance.new("UIListLayout")
	tabList.FillDirection = Enum.FillDirection.Horizontal
	tabList.SortOrder = Enum.SortOrder.LayoutOrder
	tabList.Padding = UDim.new(0, 6)
	tabList.VerticalAlignment = Enum.VerticalAlignment.Center
	tabList.Parent = tabBar

	-- 左右留白
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = tabBar

	-- 内容容器
	local contentFrame = Instance.new("Frame")
	contentFrame.Size = UDim2.new(1, -20, 1, -100)
	contentFrame.Position = UDim2.new(0, 10, 0, 90)
	contentFrame.BackgroundTransparency = 1
	contentFrame.Parent = container

	-- 注册 Tab
	DebugWindow:RegisterTab("Command", tabBar, contentFrame, function(page)
		DebugCommandsTab:CreateTab(page)
	end)

	DebugWindow:RegisterTab("Log", tabBar, contentFrame, function(page)
		DebugLogTab:CreateTab(page)
	end)
	
	--DebugWindow:RegisterTab("Browser", tabBar, contentFrame, function(page)
	--	DebugBrowserTab:CreateTab(page)
	--end)
end


function DebugWindow:RegisterTab(name, tabBar, contentFrame, drawFunc)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, #name * 10 + 20 , 1, -6) -- 上下留边
	btn.Position = UDim2.new(0, 0, 0, 3)
	btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	btn.Text = name
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 16
	btn.AutoButtonColor = false
	btn.Parent = tabBar
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	-- 悬浮高亮
	btn.MouseEnter:Connect(function()
		if ActiveTab and ActiveTab.Button == btn then return end
		btn.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
	end)
	btn.MouseLeave:Connect(function()
		if ActiveTab and ActiveTab.Button == btn then return end
		btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	end)

	-- 页面
	local page = Instance.new("Frame")
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = contentFrame

	drawFunc(page)

	-- 点击切换
	btn.MouseButton1Click:Connect(function()
		if ActiveTab then
			ActiveTab.Page.Visible = false
			ActiveTab.Button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		end
		page.Visible = true
		btn.BackgroundColor3 = Color3.fromRGB(110, 110, 110)
		ActiveTab = {Button = btn, Page = page}
	end)

	-- 默认激活第一个
	if not ActiveTab then
		btn.BackgroundColor3 = Color3.fromRGB(110, 110, 110)
		page.Visible = true
		ActiveTab = {Button = btn, Page = page}
	end

	table.insert(TabList, {Button = btn, Page = page})
end


return DebugWindow
