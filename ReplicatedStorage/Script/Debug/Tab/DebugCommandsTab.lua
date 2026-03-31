local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)

local DebugCommandsTab = {}

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

function DebugCommandsTab:CreateTab(container: Frame)
	-- 滚动区域
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Size = UDim2.new(1, 0, 1, -35)
	scrollingFrame.Position = UDim2.new(0, 0, 0, 0)
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.ScrollBarThickness = 6
	scrollingFrame.Parent = container

	local uiList = Instance.new("UIListLayout")
	uiList.SortOrder = Enum.SortOrder.LayoutOrder
	uiList.Padding = UDim.new(0, 8)
	uiList.Parent = scrollingFrame

	-- 底部操作栏
	local bottomBar = Instance.new("Frame")
	bottomBar.Size = UDim2.new(1, -0, 0, 25)
	bottomBar.Position = UDim2.new(0, 0, 1, -25)
	bottomBar.BackgroundTransparency = 1
	bottomBar.Parent = container

	-- 左右布局（左边折叠+搜索，右边输入+Run）
	local leftGroup = Instance.new("Frame")
	leftGroup.Size = UDim2.new(0.5, -5, 1, 0)
	leftGroup.BackgroundTransparency = 1
	leftGroup.Parent = bottomBar

	local leftLayout = Instance.new("UIListLayout")
	leftLayout.FillDirection = Enum.FillDirection.Horizontal
	leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
	leftLayout.Padding = UDim.new(0, 6)
	leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	leftLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	leftLayout.Parent = leftGroup

	local rightGroup = Instance.new("Frame")
	rightGroup.Size = UDim2.new(0.5, -5, 1, 0)
	rightGroup.Position = UDim2.new(0.5, 5, 0, 0)
	rightGroup.BackgroundTransparency = 1
	rightGroup.Parent = bottomBar

	local rightLayout = Instance.new("UIListLayout")
	rightLayout.FillDirection = Enum.FillDirection.Horizontal
	rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
	rightLayout.Padding = UDim.new(0, 6)
	rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	rightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	rightLayout.Parent = rightGroup

	-- 折叠展开按钮
	local toggleAllBtn = Instance.new("TextButton")
	toggleAllBtn.Size = UDim2.new(0, 130, 1, 0)
	toggleAllBtn.Text = "Collapse All"
	toggleAllBtn.Font = Enum.Font.GothamBold
	toggleAllBtn.TextSize = 16
	toggleAllBtn.TextColor3 = Color3.new(1,1,1)
	toggleAllBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
	toggleAllBtn.Parent = leftGroup
	Instance.new("UICorner", toggleAllBtn).CornerRadius = UDim.new(0, 6)

	-- 搜索框
	local searchBox = Instance.new("TextBox")
	searchBox.Text = ""
	searchBox.Size = UDim2.new(0, 200, 1, 0)
	searchBox.PlaceholderText = "🔍 Search..."
	searchBox.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	searchBox.TextColor3 = Color3.new(1, 1, 1)
	searchBox.Font = Enum.Font.Gotham
	searchBox.TextSize = 16
	searchBox.ClearTextOnFocus = false
	searchBox.Parent = leftGroup
	Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 6)

	-- 命令参数输入
	local paramInput = Instance.new("TextBox")
	paramInput.Size = UDim2.new(0, 280, 1, 0)
	paramInput.PlaceholderText = "Command Param"
	paramInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	paramInput.TextColor3 = Color3.new(1, 1, 1)
	paramInput.Font = Enum.Font.Gotham
	paramInput.TextSize = 18
	paramInput.Text = ""
	paramInput.Parent = rightGroup
	Instance.new("UICorner", paramInput).CornerRadius = UDim.new(0, 6)

	-- Run 按钮
	local sendButton = Instance.new("TextButton")
	sendButton.Size = UDim2.new(0, 100, 1, 0)
	sendButton.Text = "Run"
	sendButton.Font = Enum.Font.GothamBold
	sendButton.TextSize = 18
	sendButton.TextColor3 = Color3.new(1,1,1)
	sendButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
	sendButton.Parent = rightGroup
	Instance.new("UICorner", sendButton).CornerRadius = UDim.new(0, 6)

	-- 分组存储
	local groups = {}

	-- 动态加载命令
	NetClient:Request("Debug", "GetCommandList", nil, function(result)
		for _, data in ipairs(result) do
			if not data then continue end

			-- 如果没有分组，先建一个
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

				local header = Instance.new("TextButton")
				header.Size = UDim2.new(1, 0, 0, 30)
				header.BackgroundColor3 = Color3.fromRGB(71, 71, 71)
				header.Font = Enum.Font.GothamBold
				header.TextSize = 18
				header.TextColor3 = data.Color or Color3.fromRGB(200, 200, 200)
				header.TextXAlignment = Enum.TextXAlignment.Left
				header.Text = " ▼  " .. data.Icon .. " " .. data.Module
				header.Parent = groupFrame
				Instance.new("UICorner", header).CornerRadius = UDim.new(0, 6)

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

				local expanded = true
				header.MouseButton1Click:Connect(function()
					expanded = not expanded
					contentFrame.Visible = expanded
					header.Text = (expanded and " ▼  " or " ▶  ") .. data.Icon .. " " .. data.Module
					groups[data.Module].Expanded = expanded
				end)

				groups[data.Module] = {
					Group = groupFrame,
					Header = header,
					Content = contentFrame,
					Expanded = expanded,
					Buttons = {},
					Icon = data.Icon,
				}
			end

			local group = groups[data.Module]

			local button = Instance.new("TextButton")
			button.Size = UDim2.new(0, 220, 0, 30)
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
				NetClient:Request("Debug", "ExecuteCommand", {
					Module = data.Module,
					Action = data.Action,
					Param = paramInput.Text
				}, function()
					paramInput.Text = ""
				end)
			end)

			table.insert(group.Buttons, {Btn = button, Action = data.Action})
		end

		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y)
	end)

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

	-- 全部展开/收起
	local allExpanded = true
	toggleAllBtn.MouseButton1Click:Connect(function()
		allExpanded = not allExpanded
		toggleAllBtn.Text = allExpanded and "Collapse All" or "Expand All"

		for moduleName, group in pairs(groups) do
			group.Content.Visible = allExpanded
			group.Header.Text = (allExpanded and " ▼  " or " ▶  ")  .. group.Icon .. " "  .. moduleName
			group.Expanded = allExpanded
		end

		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y)
	end)
end

return DebugCommandsTab
