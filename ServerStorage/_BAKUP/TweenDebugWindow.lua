--local RunService = game:GetService("RunService")
--local TweenManager = require(game.ReplicatedStorage.ScriptAlias.TweenManager)

--local TweenDebugWindow = {}

--RunService.Heartbeat:Connect(function(deltaTime)
--	TweenDebugWindow:Update(deltaTime)
--end)

--local KeyList = {
--	"TweenType",
--	"Target",
--	"From",
--	"To",
--	"Delay",
--	"Duration",
--	"EaseType",
--	"LoopType",
--	"State",
--	"NormalizedTime",
--}

--TweenDebugWindow.Rows = {}

--function TweenDebugWindow:GetTweenerList()
--	return TweenManager:GetTweenerList()
--end

--function TweenDebugWindow:CreateWindow(container)
--	container:ClearAllChildren()
--	self.Rows = {}

--	-- 表头
--	local header = Instance.new("Frame")
--	header.Name = "Header"
--	header.Size = UDim2.new(1, 0, 0, 24)
--	header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
--	header.BackgroundTransparency = 0
--	header.BorderSizePixel = 0
--	header.Parent = container

--	local headerLayout = Instance.new("UIListLayout")
--	headerLayout.FillDirection = Enum.FillDirection.Horizontal
--	headerLayout.SortOrder = Enum.SortOrder.LayoutOrder
--	headerLayout.Parent = header

--	for _, key in ipairs(KeyList) do
--		local label = Instance.new("TextLabel")
--		label.Size = UDim2.new(1 / #KeyList, -1, 1, 0)
--		label.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
--		label.BorderSizePixel = 0
--		label.Text = key
--		label.Font = Enum.Font.Code
--		label.TextSize = 14
--		label.TextColor3 = Color3.fromRGB(255, 255, 255)
--		label.TextXAlignment = Enum.TextXAlignment.Center
--		label.Parent = header

--		-- 列分割线
--		local divider = Instance.new("Frame")
--		divider.Size = UDim2.new(0, 1, 1, 0)
--		divider.Position = UDim2.new(1, -1, 0, 0)
--		divider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
--		divider.BorderSizePixel = 0
--		divider.Parent = label
--	end

--	-- 滚动区域
--	local scroll = Instance.new("ScrollingFrame")
--	scroll.Size = UDim2.new(1, 0, 1, -24)
--	scroll.Position = UDim2.new(0, 0, 0, 24)
--	scroll.BackgroundTransparency = 1
--	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
--	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
--	scroll.ScrollBarThickness = 6
--	scroll.Parent = container
--	self._scroll = scroll

--	local listLayout = Instance.new("UIListLayout")
--	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
--	listLayout.Parent = scroll
--end

--function TweenDebugWindow:GetRow(id, index, tweener)
--	local row = self.Rows[id]
--	if row then
--		if index % 2 == 0 then
--			row.Frame.BackgroundColor3 = Color3.fromRGB(47, 47, 47)
--		else
--			row.Frame.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
--		end
--	else
--		local frame = Instance.new("Frame")
--		frame.Name = "Row" .. id
--		frame.Size = UDim2.new(1, 0, 0, 22)
--		frame.BorderSizePixel = 0

--		if index % 2 == 0 then
--			frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
--		else
--			frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
--		end

--		frame.Parent = self._scroll

--		local rowLayout = Instance.new("UIListLayout")
--		rowLayout.FillDirection = Enum.FillDirection.Horizontal
--		rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
--		rowLayout.Parent = frame

--		local cells = {}
--		for _, key in ipairs(KeyList) do
--			local cell = Instance.new("TextLabel")
--			cell.Name = key .. "Cell"
--			cell.Size = UDim2.new(1 / #KeyList, -1, 1, 0)
--			cell.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
--			cell.BackgroundTransparency = 0.2
--			cell.BorderSizePixel = 0
--			cell.Font = Enum.Font.Code
--			cell.TextSize = 14
--			cell.TextColor3 = Color3.fromRGB(220, 220, 220)
--			cell.TextXAlignment = Enum.TextXAlignment.Left
--			cell.TextTruncate = Enum.TextTruncate.AtEnd
--			cell.TextWrapped = false
--			cell.Text = ""
--			cell.Parent = frame

--			-- 内边距
--			local padding = Instance.new("UIPadding")
--			padding.PaddingLeft = UDim.new(0, 6)
--			padding.Parent = cell

--			-- 列分割线
--			local divider = Instance.new("Frame")
--			divider.Size = UDim2.new(0, 1, 1, 0)
--			divider.Position = UDim2.new(1, -1, 0, 0)
--			divider.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
--			divider.BorderSizePixel = 0
--			divider.Parent = cell

--			cells[key] = cell
--		end

--		-- 行底部分界线
--		local rowBorder = Instance.new("Frame")
--		rowBorder.Size = UDim2.new(1, 0, 0, 1)
--		rowBorder.Position = UDim2.new(0, 0, 1, -1)
--		rowBorder.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
--		rowBorder.BorderSizePixel = 0
--		rowBorder.Parent = frame	
		
--		row = {Frame = frame, Cells = cells}
--		self.Rows[id] = row
--	end
	
--	for _, key in ipairs(KeyList) do
--		local val = tweener[key]
--		row.Cells[key].Text = tostring(val or "N/A")
--	end

--	return self.Rows[id]
--end

--function TweenDebugWindow:Update(deltaTime)
--	local tweeners = self:GetTweenerList()
--	local activeIds = {}
--	local index = 1

--	for id, tweener in pairs(tweeners) do
--		local row = self:GetRow(id, index, tweener)
--		index += 1
--		activeIds[id] = true
--	end

--	for id, row in pairs(self.Rows) do
--		if not activeIds[id] then
--			row.Frame:Destroy()
--			self.Rows[id] = nil
--		end
--	end
--end

--return TweenDebugWindow
