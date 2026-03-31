local PluginManagerWindow = {}

local WindowTitle = "Plugin Manager"
local WidgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	true, true,
	960, 600,
	300, 200
)

local function prettifyName(str: string): string
	str = str:gsub("_", " ")
	str = str:gsub("([a-z])([A-Z])", "%1 %2")
	str = str:gsub("%s+", " ")

	local words = {}
	for word in str:gmatch("%S+") do
		table.insert(words, word:sub(1,1):upper() .. word:sub(2):lower())
	end

	return table.concat(words, " ")
end

function PluginManagerWindow:GetPluginList(plugin)
	local path = game.ReplicatedStorage.Plugins.Command
	local scirptList = {}
	for _, obj in ipairs(path:GetDescendants()) do
		if obj:IsA("ModuleScript") then
			table.insert(scirptList, obj)
		end
	end
	
	local result = {}
	for _, moduleScript in ipairs(scirptList) do
		local module = require(moduleScript)
		for funcName, func in pairs(module) do
			if typeof(func) ~= "function" then continue end
			if funcName == "Init" then
				func(plugin)
				continue
			end
			
			local data = {
				Script = module,
				Module = moduleScript.Name,
				Action = funcName,
				Function = func,
				Color = module.Color,
				Icon = module.Icon
			}
			
			table.insert(result, data)
		end
	end
	
	return result
end

function PluginManagerWindow:CreateWindow(plugin)
	local widget = plugin:CreateDockWidgetPluginGui(WindowTitle, WidgetInfo)
	widget.Title = "🔧 "..WindowTitle
	widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	-- 主容器
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 1, 0)
	container.Position = UDim2.new(0.5, 0, 0.5, 0)
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	container.BackgroundTransparency = 0.05
	container.Parent = widget
	Instance.new("UICorner", container).CornerRadius = UDim.new(0, 12)

	-- 顶部标题栏
	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 40)
	titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	titleBar.Parent = container
	Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Text = "🔧 "..WindowTitle
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 20
	titleLabel.TextColor3 = Color3.new(1,1,1)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(0.4, 0, 1, 0)
	titleLabel.Position = UDim2.new(0, 10, 0, 0)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = titleBar

	-- 搜索框
	local searchBox = Instance.new("TextBox")
	searchBox.Text = ""
	searchBox.Size = UDim2.new(0.35, -10, 0.75, 0)
	searchBox.Position = UDim2.new(0.4, 0, 0.125, 0)
	searchBox.PlaceholderText = "🔍 Search..."
	searchBox.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	searchBox.TextColor3 = Color3.new(1, 1, 1)
	searchBox.Font = Enum.Font.Gotham
	searchBox.TextSize = 16
	searchBox.ClearTextOnFocus = false
	searchBox.Parent = titleBar
	Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 6)

	-- 全部展开/收起按钮
	local toggleAllBtn = Instance.new("TextButton")
	toggleAllBtn.Size = UDim2.new(0.2, -10, 0.75, 0)
	toggleAllBtn.Position = UDim2.new(0.75, 0, 0.125, 0)
	toggleAllBtn.Text = "Collapse All"
	toggleAllBtn.Font = Enum.Font.GothamBold
	toggleAllBtn.TextSize = 16
	toggleAllBtn.TextColor3 = Color3.new(1,1,1)
	toggleAllBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
	toggleAllBtn.Parent = titleBar
	Instance.new("UICorner", toggleAllBtn).CornerRadius = UDim.new(0, 6)

	-- 滚动区域（分组和命令按钮）
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Size = UDim2.new(1, -20, 1, 0) 
	scrollingFrame.Position = UDim2.new(0, 10, 0, 50)
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.ScrollBarThickness = 6
	scrollingFrame.Parent = container

	local uiList = Instance.new("UIListLayout")
	uiList.SortOrder = Enum.SortOrder.LayoutOrder
	uiList.Padding = UDim.new(0, 8)
	uiList.Parent = scrollingFrame

	-- 存储分组信息
	local groups = {}

	-- 动态加载分组和按钮
	local pluginScriptList = PluginManagerWindow:GetPluginList(plugin)
	for _, data in ipairs(pluginScriptList) do
		if not data then continue end

		-- 如果该模块还没有分组，就创建一个
		if not groups[data.Module] then
			local groupFrame = Instance.new("Frame")
			groupFrame.BackgroundTransparency = 1
			groupFrame.Size = UDim2.new(1, 0, 0, 0)
			groupFrame.AutomaticSize = Enum.AutomaticSize.Y
			groupFrame.Parent = scrollingFrame

			local listLayout = Instance.new("UIListLayout")
			listLayout.SortOrder = Enum.SortOrder.LayoutOrder
			listLayout.Padding = UDim.new(0, 5)
			listLayout.Parent = groupFrame

			-- 标题栏
			local header = Instance.new("TextButton")
			header.Size = UDim2.new(1, 0, 0, 30)
			header.BackgroundColor3 = Color3.fromRGB(71, 71, 71)
			header.Font = Enum.Font.GothamBold
			header.TextSize = 18
			header.TextColor3 = data.Color or Color3.fromRGB(70, 70, 70)
			header.TextXAlignment = Enum.TextXAlignment.Left
			header.Text = " ▼  " .. data.Icon .. " " .. prettifyName(data.Module)
			header.Parent = groupFrame
			Instance.new("UICorner", header).CornerRadius = UDim.new(0, 6)

			-- 内容区
			local contentFrame = Instance.new("Frame")
			contentFrame.BackgroundTransparency = 1
			contentFrame.Size = UDim2.new(1, 0, 0, 0)
			contentFrame.AutomaticSize = Enum.AutomaticSize.Y
			contentFrame.Parent = groupFrame

			local gridLayout = Instance.new("UIGridLayout")
			gridLayout.CellSize = UDim2.new(0, 160, 0, 30)
			gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
			gridLayout.FillDirection = Enum.FillDirection.Horizontal
			gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
			gridLayout.Parent = contentFrame

			-- 折叠逻辑
			local expanded = true
			header.MouseButton1Click:Connect(function()
				expanded = not expanded
				contentFrame.Visible = expanded
				header.Text = (expanded and " ▼  " or " ▶  ") .. data.Icon .. " " ..  data.Module
				groups[data.Module].Expanded = expanded
			end)

			-- 保存分组
			groups[data.Module] = {
				Group = groupFrame,
				Header = header,
				Content = contentFrame,
				Expanded = expanded,
				Buttons = {},
				Icon = data.Icon,
			}
		end

		-- 在对应模块下创建 Action 按钮
		local group = groups[data.Module]

		local button = Instance.new("TextButton")
		button.Size = UDim2.new(0, 300, 0, 30)
		button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
		button.Text = "  "..prettifyName(data.Action)
		button.Font = Enum.Font.GothamMedium
		button.TextSize = 16
		button.TextColor3 = Color3.new(1,1,1)
		button.TextXAlignment = Enum.TextXAlignment.Left
		button.Parent = group.Content
		Instance.new("UICorner", button).CornerRadius = UDim.new(0, 4)

		button.MouseEnter:Connect(function()
			button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		end)
		button.MouseLeave:Connect(function()
			button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
		end)

		button.MouseButton1Click:Connect(function()
			local success, message = pcall(function()
				data.Function(data.Script, plugin)
			end)
			
			if not success then
				warn("[Plugin] Execute Fail : ", data.Module, data.Action, debug.traceback(message, 2))
			end
		end)

		table.insert(group.Buttons, {Btn = button, Action = data.Action})
	end

	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y)

	-- 搜索逻辑
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local keyword = string.lower(searchBox.Text)

		for moduleName, group in pairs(groups) do
			local anyVisible = false
			for _, item in ipairs(group.Buttons) do
				local matchText = string.lower(moduleName .. " " .. item.Action)
				local visible = (keyword == "" or string.find(matchText, keyword) ~= nil)
				item.Btn.Visible = visible
				if visible then
					anyVisible = true
				end
			end
			group.Group.Visible = anyVisible
		end

		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y)
	end)

	-- 全部展开/收起逻辑
	local allExpanded = true
	toggleAllBtn.MouseButton1Click:Connect(function()
		allExpanded = not allExpanded
		toggleAllBtn.Text = allExpanded and "Collapse All" or "Expand All"

		for moduleName, group in pairs(groups) do
			group.Content.Visible = allExpanded
			group.Header.Text = (allExpanded and "▼  " or "▶  ")  .. group.Icon .. " "  .. moduleName
			group.Expanded = allExpanded
		end

		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y)
	end)

	return widget
end

return PluginManagerWindow
