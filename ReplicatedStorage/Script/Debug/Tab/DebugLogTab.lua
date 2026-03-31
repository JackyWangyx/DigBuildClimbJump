-- DebugLogTab.lua
-- Interactive, beautified in-game log viewer with collapsible tables
local LogService = game:GetService("LogService")

local DebugLogTab = {}

-- Styles
local STYLES = {
	Info = {
		Color = Color3.fromRGB(220, 220, 220),
		Bg = Color3.fromRGB(28, 28, 30),
		BadgeColor = Color3.fromRGB(90, 90, 95),
		TextSize = 16,
		BadgeTextSize = 13,
		Bold = false,
	},
	Warning = {
		Color = Color3.fromRGB(255, 200, 90),
		Bg = Color3.fromRGB(44, 36, 16),
		BadgeColor = Color3.fromRGB(120, 85, 20),
		TextSize = 17,
		BadgeTextSize = 13,
		Bold = true,
	},
	Error = {
		Color = Color3.fromRGB(255, 105, 105),
		Bg = Color3.fromRGB(55, 24, 24),
		BadgeColor = Color3.fromRGB(140, 40, 40),
		TextSize = 18,
		BadgeTextSize = 13,
		Bold = true,
	},
}

local DEFAULT_STYLE = STYLES.Info
local HOVER_BG = Color3.fromRGB(60, 60, 60)
local MAX_TABLE_DEPTH = 6

local LogCounter = 0
local ScrollingFrameRef, UIListRef

-- safe tostring wrapper
local function safeToString(v)
	local ok, res = pcall(function() return tostring(v) end)
	if ok then return res end
	return "<unprintable>"
end

-- Prevent cyclic printing and track depth
local function isArrayLike(t)
	local n = 0
	for k, _ in pairs(t) do
		n = n + 1
		if type(k) ~= "number" then
			return false
		end
	end
	return n > 0
end

-- create a primitive text line (auto-size)
local function createTextLine(parent, text, style, leftPadding)
	leftPadding = leftPadding or 8
	style = style or DEFAULT_STYLE

	local label = Instance.new("TextLabel")
	label.Name = "LogLine"
	label.BackgroundTransparency = 1
	label.TextWrapped = true
	label.RichText = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.Font = Enum.Font.Code
	label.TextColor3 = style.Color
	label.TextSize = style.TextSize
	if style.Bold then
		label.Text = "<b>" .. safeToString(text) .. "</b>"
	else
		label.Text = safeToString(text)
	end
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.Size = UDim2.new(1, -leftPadding, 0, 0)
	label.Parent = parent

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, leftPadding)
	padding.PaddingTop = UDim.new(0, 2)
	padding.PaddingBottom = UDim.new(0, 2)
	padding.Parent = label

	return label
end

-- create a collapsible table node
local function createTableNode(parent, labelKey, tbl, style, leftPadding, depth, seen)
	leftPadding = leftPadding or 8
	depth = depth or 1
	seen = seen or {}

	-- detect cycles
	if seen[tbl] then
		return createTextLine(parent, labelKey .. " = <cyclic reference>", style, leftPadding)
	end
	seen[tbl] = true

	-- container frame for this node
	local nodeFrame = Instance.new("Frame")
	nodeFrame.BackgroundTransparency = 1
	nodeFrame.Size = UDim2.new(1, 0, 0, 0)
	nodeFrame.AutomaticSize = Enum.AutomaticSize.Y
	nodeFrame.Parent = parent

	-- header: a button with fold/unfold arrow
	local header = Instance.new("TextButton")
	header.Name = "TableHeader"
	header.AutoButtonColor = true
	header.BackgroundTransparency = 1
	header.Size = UDim2.new(1, -leftPadding, 0, 20)
	header.Font = Enum.Font.Code
	header.TextSize = math.max(14, style.TextSize - 2)
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.TextYAlignment = Enum.TextYAlignment.Center
	header.RichText = true
	header.TextColor3 = style.Color
	header.Text = string.format("▶ %s = { ... }", labelKey or "<table>")
	header.Parent = nodeFrame

	local headerPadding = Instance.new("UIPadding")
	headerPadding.PaddingLeft = UDim.new(0, leftPadding)
	headerPadding.Parent = header

	-- child container (hidden when collapsed)
	local childrenContainer = Instance.new("Frame")
	childrenContainer.Name = "Children"
	childrenContainer.BackgroundTransparency = 1
	childrenContainer.Size = UDim2.new(1, 0, 0, 0)
	childrenContainer.AutomaticSize = Enum.AutomaticSize.Y
	childrenContainer.Visible = false
	childrenContainer.Parent = nodeFrame

	local childrenLayout = Instance.new("UIListLayout")
	childrenLayout.SortOrder = Enum.SortOrder.LayoutOrder
	childrenLayout.Padding = UDim.new(0, 2)
	childrenLayout.Parent = childrenContainer

	local childPadding = Instance.new("UIPadding")
	childPadding.PaddingLeft = UDim.new(0, 6)
	childPadding.Parent = childrenContainer

	-- If too deep, show truncated
	if depth >= MAX_TABLE_DEPTH then
		createTextLine(childrenContainer, "... (max depth reached)", style, leftPadding + 8)
	else
		-- iterate keys in a stable-ish order: numeric ascending then strings alphabetical
		local numericKeys = {}
		local otherKeys = {}
		for k in pairs(tbl) do
			if type(k) == "number" then
				table.insert(numericKeys, k)
			else
				table.insert(otherKeys, k)
			end
		end
		table.sort(numericKeys)
		table.sort(otherKeys, function(a,b) return tostring(a) < tostring(b) end)

		for _, k in ipairs(numericKeys) do
			local v = tbl[k]
			if type(v) == "table" then
				createTableNode(childrenContainer, "["..tostring(k).."]", v, style, leftPadding + 12, depth + 1, seen)
			else
				createTextLine(childrenContainer, "["..tostring(k).."] = " .. safeToString(v), style, leftPadding + 12)
			end
		end
		for _, k in ipairs(otherKeys) do
			local v = tbl[k]
			if type(v) == "table" then
				createTableNode(childrenContainer, tostring(k), v, style, leftPadding + 12, depth + 1, seen)
			else
				createTextLine(childrenContainer, tostring(k) .. " = " .. safeToString(v), style, leftPadding + 12)
			end
		end
	end

	-- toggle function
	local expanded = false
	local function setHeaderText()
		if expanded then
			header.Text = string.format("▼ %s = {", labelKey or "<table>")
		else
			header.Text = string.format("▶ %s = { ... }", labelKey or "<table>")
		end
	end

	header.Activated:Connect(function()
		expanded = not expanded
		childrenContainer.Visible = expanded
		setHeaderText()
		-- update scroll canvas after toggle (small delay is OK)
		local abs = UIListRef.AbsoluteContentSize.Y
		ScrollingFrameRef.CanvasSize = UDim2.new(0, 0, 0, abs + 8)
	end)

	-- initial header text
	setHeaderText()

	-- unmark from seen when nodeFrame destroyed (allow reusing elsewhere)
	nodeFrame.Destroying:Connect(function()
		seen[tbl] = nil
	end)

	return nodeFrame
end

-- create one log item
local function createLogItem(container, msgArgs, typeName)
	LogCounter = LogCounter + 1
	local style = STYLES[typeName] or DEFAULT_STYLE
	local order = LogCounter

	-- outer frame for the log item
	local item = Instance.new("Frame")
	item.Name = "LogItem_" .. tostring(order)
	item.BackgroundColor3 = style.Bg
	item.Size = UDim2.new(1, -8, 0, 0)
	item.AutomaticSize = Enum.AutomaticSize.Y
	item.LayoutOrder = order
	item.ClipsDescendants = true
	item.Parent = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = item

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 6)
	padding.PaddingRight = UDim.new(0, 6)
	padding.PaddingTop = UDim.new(0, 6)
	padding.PaddingBottom = UDim.new(0, 6)
	padding.Parent = item

	local itemLayout = Instance.new("UIListLayout")
	itemLayout.SortOrder = Enum.SortOrder.LayoutOrder
	itemLayout.Padding = UDim.new(0, 4)
	itemLayout.Parent = item

	-- header row (timestamp + badge + summary)
	local headerRow = Instance.new("Frame")
	headerRow.BackgroundTransparency = 1
	headerRow.Size = UDim2.new(1, 0, 0, 20)
	headerRow.AutomaticSize = Enum.AutomaticSize.XY
	headerRow.Parent = item

	local headerLayout = Instance.new("UIListLayout")
	headerLayout.SortOrder = Enum.SortOrder.LayoutOrder
	headerLayout.FillDirection = Enum.FillDirection.Horizontal
	headerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	headerLayout.Padding = UDim.new(0, 8)
	headerLayout.Parent = headerRow

	-- Badge
	local badge = Instance.new("TextLabel")
	badge.Name = "Badge"
	badge.Size = UDim2.new(0, 68, 0, 20)
	badge.BackgroundColor3 = style.BadgeColor
	badge.Text = (typeName == "Warning" and "⚠ WARNING") or (typeName == "Error" and "✖ ERROR") or "INFO"
	badge.TextSize = style.BadgeTextSize
	badge.Font = Enum.Font.Code
	badge.TextColor3 = Color3.new(1,1,1)
	badge.TextXAlignment = Enum.TextXAlignment.Center
	badge.TextYAlignment = Enum.TextYAlignment.Center
	badge.Parent = headerRow
	local badgeCorner = Instance.new("UICorner")
	badgeCorner.CornerRadius = UDim.new(0, 4)
	badgeCorner.Parent = badge

	-- timestamp + id
	local idLabel = Instance.new("TextLabel")
	idLabel.BackgroundTransparency = 1
	idLabel.Text = string.format("[%03d] %s", order, os.date("%H:%M:%S"))
	idLabel.Font = Enum.Font.Code
	idLabel.TextSize = 14
	idLabel.TextColor3 = Color3.fromRGB(180,180,180)
	idLabel.TextXAlignment = Enum.TextXAlignment.Left
	idLabel.Size = UDim2.new(1, -76, 0, 20)
	idLabel.Parent = headerRow

	-- content container (vertical)
	local content = Instance.new("Frame")
	content.BackgroundTransparency = 1
	content.Size = UDim2.new(1, 0, 0, 0)
	content.AutomaticSize = Enum.AutomaticSize.Y
	content.Parent = item

	-- we use UIListLayout so children stack vertically
	local contentLayout = Instance.new("UIListLayout")
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Padding = UDim.new(0, 4)
	contentLayout.Parent = content

	-- add each argument
	for i, a in ipairs(msgArgs) do
		local t = typeof(a)
		if t == "table" then
			createTableNode(content, "Arg" .. i, a, style, 8, 1, {})
		else
			local str = safeToString(a)
			createTextLine(content, str, style, 8)
		end
	end

	-- hover effects (mouse on whole item)
	item.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			item.BackgroundColor3 = HOVER_BG
		end
	end)
	item.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			item.BackgroundColor3 = style.Bg
		end
	end)

	return item
end

-- Public: Create the tab UI inside given container (Frame)
function DebugLogTab:CreateTab(container)
	assert(typeof(container) == "Instance" and container:IsA("Frame"), "container must be a Frame")

	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "DebugLog_Scrolling"
	scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
	scrollingFrame.Position = UDim2.new(0, 0, 0, 0)
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.ScrollBarThickness = 8
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollingFrame.Parent = container
	ScrollingFrameRef = scrollingFrame

	local uiList = Instance.new("UIListLayout")
	uiList.SortOrder = Enum.SortOrder.LayoutOrder
	uiList.Padding = UDim.new(0, 8)
	uiList.Parent = scrollingFrame
	UIListRef = uiList

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, 8)
	uiPadding.PaddingBottom = UDim.new(0, 8)
	uiPadding.PaddingLeft = UDim.new(0, 8)
	uiPadding.PaddingRight = UDim.new(0, 8)
	uiPadding.Parent = scrollingFrame

	-- keep canvas size in sync
	uiList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		local abs = uiList.AbsoluteContentSize.Y
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, abs + 8)
		-- auto-scroll to bottom
		scrollingFrame.CanvasPosition = Vector2.new(0, math.max(0, abs - scrollingFrame.AbsoluteSize.Y + 8))
	end)

	-- connect Roblox log output
	LogService.MessageOut:Connect(function(message, messageType)
		local typeName
		if messageType == Enum.MessageType.MessageOutput then
			typeName = "Info"
		elseif messageType == Enum.MessageType.MessageWarning then
			typeName = "Warning"
		elseif messageType == Enum.MessageType.MessageError then
			typeName = "Error"
		else
			typeName = "Info"
		end
		-- MessageOut provides a single string; keep compatibility with AddLog interface
		self:AddLog(message, typeName)
	end)
end

-- Public: add log
-- Usage:
--   DebugLogTab:AddLog("some message")               -- Info default
--   DebugLogTab:AddLog("A","B","Error")              -- multiple args, last arg "Error" interpreted as type
--   DebugLogTab:AddLog({tbl, "hello"}, "Warning")    -- array-style + explicit type
function DebugLogTab:AddLog(...)
	if not ScrollingFrameRef or not UIListRef then
		warn("DebugLogTab: ScrollingFrame not initialized. Call CreateTab first.")
		return
	end

	local vargs = {...}
	if #vargs == 0 then return end

	-- detect trailing explicit type name
	local typeName = "Info"
	local last = vargs[#vargs]
	if type(last) == "string" and (last == "Info" or last == "Warning" or last == "Error") then
		typeName = last
		table.remove(vargs, #vargs)
	end

	-- if single first arg is a table and there are no others, treat it as the arg-list
	local msgArgs = {}
	if #vargs == 1 and typeof(vargs[1]) == "table" then
		-- copy the array portion (support tables of args)
		for i, v in ipairs(vargs[1]) do
			table.insert(msgArgs, v)
		end
	else
		for i, v in ipairs(vargs) do
			table.insert(msgArgs, v)
		end
	end

	-- create UI
	local item = createLogItem(ScrollingFrameRef, msgArgs, typeName)
	-- ensure layout order & canvas are updated (AbsoluteContentSize listener will handle canvas)
	item.LayoutOrder = LogCounter
end

return DebugLogTab
