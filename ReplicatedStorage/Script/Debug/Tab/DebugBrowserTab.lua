-- DebugBrowserTab.lua
-- Interactive workspace browser: tree view, icons, styles, properties panel, search/filter
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local DebugBrowserTab = {}

-- ======= Configuration / Styles =======
local UI = {
	Background = Color3.fromRGB(20,20,22),
	PanelBg = Color3.fromRGB(28,28,30),
	Border = Color3.fromRGB(45,45,48),
	Text = Color3.fromRGB(230,230,230),
	SecondaryText = Color3.fromRGB(170,170,170),
	Accent = Color3.fromRGB(100,160,255),
	Warning = Color3.fromRGB(255,170,80),
	Error = Color3.fromRGB(255,100,100),
	NodeHover = Color3.fromRGB(40,40,44),
	NodeSelected = Color3.fromRGB(60,70,95),
}

local ICON_BY_CLASS = {
	Workspace = "🌏",
	Players = "🕹️",
	Lighting = "💡",
	MaterialService = "🎨",
	ReplicatedStorage ="🪨",
	StarterPlayer = "▶️",
	SoundService = "🔊",
	Model = "📦",
	Folder = "📁",
	MeshPart = "🧩",
	Part = "🔩",
	Script = "📄",
	LocalScript = "📝",
	ModuleScript = "🗒️",
	Tool = "🛠",
	Humanoid = "🧍",
	Attachment = "📎",
	Camera = "📸",
	Terrain = "🏔️",
	Player = "🧑",
	Sound = "🔈",
	-- default fallback icon
	_default = "◦",
}

-- 常用属性尝试读取（按需扩展）
local COMMON_PROPERTIES = {
	"Name","ClassName","Parent","Archivable","Visible","Position","CFrame","Size","Anchored",
	"CanCollide","Transparency","Material","Color","BrickColor","Velocity","Orientation","Health",
	"MaxHealth","Team","Locked","Bounce","Elasticity","Mass","Velocity","Velocity",
}

local MAX_DISPLAY_CHILDREN = 200 -- 防止一次展开太多影响性能

-- ======= Internal state refs =======
local TreeScrollRef, TreeListRef, PropertiesContentRef, SearchBoxRef
local SelectedNodeButton = nil
local ContainerRef = nil

-- ======= Utility helpers =======
local function safeTostring(v)
	local ok, s = pcall(function() return tostring(v) end)
	if ok then return s end
	return "<unprintable>"
end

local function classIcon(inst)
	local c = inst.ClassName
	return ICON_BY_CLASS[c] or ICON_BY_CLASS._default
end

local function setSelected(nodeBtn)
	if SelectedNodeButton and SelectedNodeButton ~= nodeBtn then
		SelectedNodeButton.BackgroundColor3 = UI.PanelBg
	end
	SelectedNodeButton = nodeBtn
	nodeBtn.BackgroundColor3 = UI.NodeSelected
end

-- create a generic UI helper (rounded frame)
local function makeFrame(parent, props)
	local f = Instance.new("Frame")
	for k,v in pairs(props or {}) do
		f[k] = v
	end
	f.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,6)
	corner.Parent = f
	return f
end

local function makeTextButton(parent, props)
	local b = Instance.new("TextButton")
	for k,v in pairs(props or {}) do b[k] = v end
	b.AutoButtonColor = false
	b.Parent = parent
	return b
end

local function makeTextLabel(parent, props)
	local l = Instance.new("TextLabel")
	for k,v in pairs(props or {}) do l[k] = v end
	l.Parent = parent
	return l
end

-- ======= Tree node creation =======
-- nodeData: { instance = Instance, depth = number }
local function createTreeNode(parentList, nodeData)
	local inst = nodeData.instance
	local depth = nodeData.depth or 0

	-- === NodeWrapper ===
	local wrapper = Instance.new("Frame")
	wrapper.BackgroundTransparency = 1
	wrapper.Size = UDim2.new(1,0,0,0)
	wrapper.AutomaticSize = Enum.AutomaticSize.Y
	wrapper.Parent = parentList

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = wrapper

	-- === Node Button ===
	local nodeBtn = makeTextButton(wrapper, {
		BackgroundColor3 = UI.PanelBg,
		Size = UDim2.new(1, 0, 0, 28),
		Text = "",
		AutoButtonColor = true,
	})

	nodeBtn:SetAttribute("origBg", UI.PanelBg)

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0,6)
	layout.Parent = nodeBtn

	-- 左缩进
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 8 + depth * 12)
	padding.Parent = nodeBtn

	-- 图标 + 名称
	local icon = makeTextLabel(nodeBtn, {
		BackgroundTransparency = 1,
		Text = classIcon(inst),
		Font = Enum.Font.SourceSansBold,
		TextSize = 16,
		TextColor3 = UI.Text,
		Size = UDim2.new(0,20,0,20),
	})

	-- 名称
	local nameLabel = makeTextLabel(nodeBtn, {
		BackgroundTransparency = 1,
		Text = "<b>" .. inst.Name .. "</b>", --  .. inst.ClassName .. "]"
		Font = Enum.Font.Code,
		RichText = true,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = UI.Text,
		Size = UDim2.new(1,-26,1,0),
	})

	-- === 子节点容器 ===
	local childrenContainer = Instance.new("Frame")
	childrenContainer.BackgroundTransparency = 1
	childrenContainer.Size = UDim2.new(1,0,0,0)
	childrenContainer.AutomaticSize = Enum.AutomaticSize.Y
	childrenContainer.Visible = false
	childrenContainer.Parent = wrapper

	local childLayout = Instance.new("UIListLayout")
	childLayout.SortOrder = Enum.SortOrder.LayoutOrder
	childLayout.Parent = childrenContainer

	-- === 交互 ===
	local expanded = false
	nodeBtn.MouseButton1Click:Connect(function()
		setSelected(nodeBtn)
		DebugBrowserTab:ShowProperties(inst)

		-- 展开/收起
		if #inst:GetChildren() > 0 then
			expanded = not expanded
			childrenContainer.Visible = expanded
			if expanded and #childrenContainer:GetChildren() == 1 then
				for _, child in ipairs(inst:GetChildren()) do
					createTreeNode(childrenContainer, { instance = child, depth = depth+1 })
				end
			end
		end
	end)

	
	nodeBtn.MouseEnter:Connect(function()
		if SelectedNodeButton ~= nodeBtn then
			nodeBtn.BackgroundColor3 = UI.NodeHover
		end
	end)

	nodeBtn.MouseLeave:Connect(function()
		if SelectedNodeButton ~= nodeBtn then
			nodeBtn.BackgroundColor3 = UI.PanelBg
		end
	end)


	return wrapper
end

-- ======= Build / Refresh tree =======
local function clearChildren(frame)
	if not frame then return end
	for _, c in ipairs(frame:GetChildren()) do
		if not (c:IsA("UIListLayout") or c:IsA("UIPadding")) then
			c:Destroy()
		end
	end
end

local function populateTree(rootParent)
	clearChildren(rootParent)

	--local children = Workspace:GetChildren()
	local children = {}
	table.insert(children, game.Workspace)
	table.insert(children, game.ReplicatedStorage)
	table.insert(children, game.Lighting)
	table.insert(children, game.Players)
	--table.insert(children, game.ReplicatedFirst)
	table.insert(children, game.StarterPlayer)
	table.insert(children, game.SoundService)
	table.insert(children, game.MaterialService)
	
	table.sort(children, function(a,b)
		return string.lower(a.Name) < string.lower(b.Name)
	end)

	for _, child in ipairs(children) do
		createTreeNode(rootParent, { instance = child, depth = 0 })
	end
end


-- ======= Search / Filter =======
local function matchesQuery(inst, q)
	if not q or q == "" then return true end
	q = string.lower(q)
	if string.find(string.lower(inst.Name), q, 1, true) then return true end
	if string.find(string.lower(inst.ClassName), q, 1, true) then return true end
	-- you can add more matching rules (e.g., attribute names/values)
	return false
end

-- Walk workspace tree and create nodes only for items that match or whose descendants match
local function populateFilteredTree(container, query)
	clearChildren(container)

	local function recurse(parentInst, depth, parentContainer, orderRef)
		local children = parentInst:GetChildren()
		table.sort(children, function(a,b) return string.lower(a.Name) < string.lower(b.Name) end)
		for _, child in ipairs(children) do
			-- check if this node or any descendant matches
			local nodeMatches = matchesQuery(child, query)
			-- we do a quick descendant search (breadth-limited for perf)
			local descendantMatches = false
			local queue = { child }
			local qidx = 1
			local maxCheck = 500 -- limit
			local checks = 0
			while queue[qidx] and checks < maxCheck do
				local cur = table.remove(queue, 1)
				checks = checks + 1
				if matchesQuery(cur, query) then
					descendantMatches = true
					break
				end
				for _, gc in ipairs(cur:GetChildren()) do
					table.insert(queue, gc)
				end
			end

			if nodeMatches or descendantMatches then
				local nodeBtn, childrenContainer = createTreeNode(parentContainer, { instance = child, depth = depth })
				nodeBtn.LayoutOrder = orderRef.count
				orderRef.count = orderRef.count + 1
				-- If descendantMatches but not nodeMatches, expand so user can see matches
				if childrenContainer and descendantMatches and not nodeMatches then
					-- force create and show children
					childrenContainer.Visible = true
					-- fill children but keep them filtered
					local gcOrderRef = { count = 1 }
					for _, gc in ipairs(child:GetChildren()) do
						recurse(child, depth + 1, parentContainer, orderRef)
					end
				end
			end
		end
	end

	local orderRef = { count = 1 }
	-- root-level: workspace children
	for _, top in ipairs(Workspace:GetChildren()) do
		if matchesQuery(top, query) then
			local nodeBtn, childrenContainer = createTreeNode(container, { instance = top, depth = 0 })
			nodeBtn.LayoutOrder = orderRef.count
			orderRef.count = orderRef.count + 1
		else
			-- if any descendant matches, include top
			local found = false
			local queue = { top }
			while #queue > 0 and not found do
				local cur = table.remove(queue, 1)
				for _, gc in ipairs(cur:GetChildren()) do
					if matchesQuery(gc, query) then
						found = true
						break
					end
					table.insert(queue, gc)
				end
			end
			if found then
				local nodeBtn, childrenContainer = createTreeNode(container, { instance = top, depth = 0 })
				nodeBtn.LayoutOrder = orderRef.count
				orderRef.count = orderRef.count + 1
				-- optionally expand
				if childrenContainer then
					childrenContainer.Visible = true
				end
			end
		end
	end

	-- update canvas
	if TreeListRef then
		local abs = TreeListRef.AbsoluteSize.Y
		if TreeScrollRef then
			TreeScrollRef.CanvasSize = UDim2.new(0,0,0,abs + 8)
		end
	end
end

-- ======= Properties Panel =======
local function addPropertyRow(parent, key, value, order)
	local row = makeFrame(parent, {
		BackgroundColor3 = Color3.fromRGB(32,32,36),
		Size = UDim2.new(1,0,0,0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	row.LayoutOrder = order

	local rowLayout = Instance.new("UIListLayout")
	rowLayout.FillDirection = Enum.FillDirection.Horizontal
	rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
	rowLayout.Padding = UDim.new(0,6)
	rowLayout.Parent = row

	local keyLabel = makeTextLabel(row, {
		BackgroundTransparency = 1,
		Text = tostring(key),
		Font = Enum.Font.Code,
		TextSize = 13,
		TextColor3 = UI.SecondaryText,
		Size = UDim2.new(0,120,0,18),
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local valueLabel = makeTextLabel(row, {
		BackgroundTransparency = 1,
		Text = safeTostring(value),
		Font = Enum.Font.Code,
		TextSize = 13,
		TextColor3 = UI.Text,
		Size = UDim2.new(1,-120,0,0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
	})

	return row
end


function DebugBrowserTab:ShowProperties(inst)
	if not PropertiesContentRef then return end
	-- clear
	for _, c in ipairs(PropertiesContentRef:GetChildren()) do
		if not (c:IsA("UIListLayout") or c:IsA("UIPadding")) then c:Destroy() end
	end

	-- header
	local header = makeTextLabel(PropertiesContentRef, {
		BackgroundTransparency = 1,
		Text = ("Selected: %s  (%s)"):format(inst.Name, inst.ClassName),
		Font = Enum.Font.Code,
		TextSize = 16,
		TextColor3 = UI.Text,
		Size = UDim2.new(1,0,0,22),
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	header.LayoutOrder = 1

	-- Attributes section
	local attrs = inst:GetAttributes()
	local order = 2
	if next(attrs) then
		local tlabel = makeTextLabel(PropertiesContentRef, {
			BackgroundTransparency = 1,
			Text = "Attributes:",
			Font = Enum.Font.Code,
			TextSize = 14,
			TextColor3 = UI.SecondaryText,
			Size = UDim2.new(1,0,0,18),
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		tlabel.LayoutOrder = order; order = order + 1

		for k,v in pairs(attrs) do
			local line = makeTextLabel(PropertiesContentRef, {
				BackgroundTransparency = 1,
				Text = string.format("%s = %s", tostring(k), safeTostring(v)),
				Font = Enum.Font.Code,
				TextSize = 13,
				TextColor3 = UI.Text,
				Size = UDim2.new(1,0,0,16),
				TextXAlignment = Enum.TextXAlignment.Left,
			})
			line.LayoutOrder = order; order = order + 1
		end
	end

	-- Common properties
	local propHeader = makeTextLabel(PropertiesContentRef, {
		BackgroundTransparency = 1,
		Text = "Properties:",
		Font = Enum.Font.Code,
		TextSize = 14,
		TextColor3 = UI.SecondaryText,
		Size = UDim2.new(1,0,0,18),
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	propHeader.LayoutOrder = order; order = order + 1

	for _, prop in ipairs(COMMON_PROPERTIES) do
		local ok, val = pcall(function() return inst[prop] end)
		if ok then
			addPropertyRow(PropertiesContentRef, prop, val, order)
			order += 1
		end
	end


	-- children count
	local childCountLine = makeTextLabel(PropertiesContentRef, {
		BackgroundTransparency = 1,
		Text = ("Children: %d"):format(#inst:GetChildren()),
		Font = Enum.Font.Code,
		TextSize = 13,
		TextColor3 = UI.SecondaryText,
		Size = UDim2.new(1,0,0,16),
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	childCountLine.LayoutOrder = order; order = order + 1

	-- update canvas in case
	PropertiesContentRef:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() end)
end

-- ======= Create UI =======
function DebugBrowserTab:CreateTab(container)
	assert(typeof(container) == "Instance" and container:IsA("Frame"), "CreateTab requires a Frame container")

	ContainerRef = container

	-- clear container
	for _, c in ipairs(container:GetChildren()) do c:Destroy() end
	container.BackgroundColor3 = UI.Background

	-- header / toolbar
	local toolbar = makeFrame(container, {
		BackgroundColor3 = UI.PanelBg,
		Size = UDim2.new(1,0,0,36),
		Position = UDim2.new(0,0,0,0),
	})
	toolbar.LayoutOrder = 0

	local toolbarLayout = Instance.new("UIListLayout")
	toolbarLayout.FillDirection = Enum.FillDirection.Horizontal
	toolbarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	toolbarLayout.Padding = UDim.new(0,8)
	toolbarLayout.Parent = toolbar

	local tbPadding = Instance.new("UIPadding")
	tbPadding.PaddingLeft = UDim.new(0,8)
	tbPadding.PaddingRight = UDim.new(0,8)
	tbPadding.PaddingTop = UDim.new(0,6)
	tbPadding.Parent = toolbar

	-- Search box
	local searchBox = Instance.new("TextBox")
	searchBox.PlaceholderText = "Search by name or class..."
	searchBox.Font = Enum.Font.Code
	searchBox.TextSize = 14
	searchBox.ClearTextOnFocus = false
	searchBox.BackgroundColor3 = Color3.fromRGB(36,36,38)
	searchBox.TextColor3 = UI.Text
	searchBox.Size = UDim2.new(0.5, -16, 0, 24)
	searchBox.Parent = toolbar
	searchBox.Text = ""
	SearchBoxRef = searchBox

	local refreshBtn = makeTextButton(toolbar, {
		Text = "Refresh",
		BackgroundColor3 = UI.Border,
		TextColor3 = UI.Text,
		Font = Enum.Font.Code,
		TextSize = 14,
		Size = UDim2.new(0,80,0,24),
	})
	refreshBtn.MouseButton1Click:Connect(function()
		populateTree(TreeListRef.Parent)
	end)

	-- main split: left tree, right properties
	local main = makeFrame(container, {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, -40),
		Position = UDim2.new(0,0,0,40),
	})
	main.LayoutOrder = 1

	-- left panel
	local leftPanel = makeFrame(main, {
		BackgroundColor3 = UI.PanelBg,
		Size = UDim2.new(0.35, -6, 1, 0),
		Position = UDim2.new(0,0,0,0),
	})
	leftPanel.Parent = main

	local leftPadding = Instance.new("UIPadding")
	leftPadding.PaddingLeft = UDim.new(0,6)
	leftPadding.PaddingRight = UDim.new(0,6)
	leftPadding.PaddingTop = UDim.new(0,6)
	leftPadding.Parent = leftPanel

	-- tree scrolling frame
	local treeScroll = Instance.new("ScrollingFrame")
	treeScroll.Parent = leftPanel
	treeScroll.BackgroundTransparency = 1
	treeScroll.Size = UDim2.new(1,0,1, -12)
	treeScroll.Position = UDim2.new(0,0,0,0)
	treeScroll.CanvasSize = UDim2.new(0,0,0,0)
	treeScroll.ScrollBarThickness = 8
	TreeScrollRef = treeScroll

	local treeList = Instance.new("Frame")
	treeList.Parent = treeScroll
	treeList.BackgroundTransparency = 1
	treeList.Size = UDim2.new(1,0,0,0)
	treeList.AutomaticSize = Enum.AutomaticSize.Y
	TreeListRef = treeList

	local treeListLayout = Instance.new("UIListLayout")
	treeListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	treeListLayout.Padding = UDim.new(0,4)
	treeListLayout.Parent = treeList

	-- right panel (properties)
	local rightPanel = makeFrame(main, {
		BackgroundColor3 = UI.PanelBg,
		Size = UDim2.new(0.65, -6, 1, 0),
		Position = UDim2.new(0.35, 6, 0, 0),
	})
	rightPanel.Parent = main

	local rightPadding = Instance.new("UIPadding")
	rightPadding.PaddingLeft = UDim.new(0,6)
	rightPadding.PaddingRight = UDim.new(0,6)
	rightPadding.PaddingTop = UDim.new(0,6)
	rightPadding.Parent = rightPanel

	local propsScroll = Instance.new("ScrollingFrame")
	propsScroll.Parent = rightPanel
	propsScroll.BackgroundTransparency = 1
	propsScroll.Size = UDim2.new(1,0,1, -12)
	propsScroll.Position = UDim2.new(0,0,0,0)
	propsScroll.CanvasSize = UDim2.new(0,0,0,0)
	propsScroll.ScrollBarThickness = 8

	local propsContent = Instance.new("Frame")
	propsContent.Parent = propsScroll
	propsContent.BackgroundTransparency = 1
	propsContent.Size = UDim2.new(1,0,0,0)
	propsContent.AutomaticSize = Enum.AutomaticSize.Y
	PropertiesContentRef = propsContent

	local propsListLayout = Instance.new("UIListLayout")
	propsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	propsListLayout.Padding = UDim.new(0,6)
	propsListLayout.Parent = propsContent

	-- keep canvas sizes synced
	treeListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		local abs = treeListLayout.AbsoluteContentSize.Y
		treeScroll.CanvasSize = UDim2.new(0,0,0,abs + 8)
	end)
	propsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		local abs = propsListLayout.AbsoluteContentSize.Y
		propsScroll.CanvasSize = UDim2.new(0,0,0,abs + 8)
	end)

	-- hook search debounced
	local debounce = 0
	local lastQuery = ""
	searchBox.Changed:Connect(function(prop)
		if prop ~= "Text" then return end
		debounce = tick()
		local myTick = debounce
		delay(0.12, function()
			if myTick ~= debounce then return end
			local q = searchBox.Text or ""
			if q == lastQuery then return end
			lastQuery = q
			-- simple behavior: if empty => full tree, else filtered tree
			if q == "" then
				populateTree(treeList)
			else
				populateFilteredTree(treeList, q)
			end
		end)
	end)

	-- initial populate
	populateTree(treeList)

	-- expose refs
	TreeScrollRef = treeScroll
	TreeListRef = treeList
	SearchBoxRef = searchBox

	-- make click on workspace objects in-game also show properties (optional)
	-- example: left click selection in explorer does show properties (we listen to selection changes in Studio only)
	--if game:GetService("RunService"):IsStudio() then
	--	local Selection = game:GetService("Selection")
	--	Selection.SelectionChanged:Connect(function()
	--		local sel = Selection:Get()
	--		if sel and #sel > 0 then
	--			DebugBrowserTab:ShowProperties(sel[1])
	--		end
	--	end)
	--end

	return container
end

-- ======= Public helper: Refresh view =======
function DebugBrowserTab:Refresh()
	if TreeListRef then
		populateTree(TreeListRef)
	end
end

return DebugBrowserTab
