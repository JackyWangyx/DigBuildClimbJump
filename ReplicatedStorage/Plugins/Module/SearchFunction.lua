local Selection = game:GetService("Selection")

local SearchFunction = {}

local function openAtLine(plugin, scriptObj, lineNumber)
	local text = scriptObj.Source
	if not text then return end

	plugin:OpenScript(scriptObj, lineNumber)
end

local luaKeywords = {
	"and","break","do","else","elseif","end","false","for","function",
	"if","in","local","nil","not","or","repeat","return","then","true","until","while"
}

local keywordSet = {}
for _, kw in ipairs(luaKeywords) do
	keywordSet[kw] = true
end

local function escapePattern(text)
	return text:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")
end

local function highlightCode(line, searchKeyword)
	local result = {}
	local index = 1

	while index <= #line do
		local c = line:sub(index,index)

		-- 1. 字符串
		if c == '"' or c == "'" then
			local quote = c
			local closing = line:find(quote, index+1)
			if closing then
				table.insert(result, '<font color="rgb(100,255,100)">'..line:sub(index, closing)..'</font>')
				index = closing + 1
			else
				table.insert(result, '<font color="rgb(100,255,100)">'..line:sub(index)..'</font>')
				break
			end

			-- 2. 数字
		elseif c:match("%d") then
			local numEnd = line:find("[^%d%.]", index) or (#line+1)
			table.insert(result, '<font color="rgb(100,200,255)">'..line:sub(index,numEnd-1)..'</font>')
			index = numEnd

			-- 3. 单词（可能是关键字或搜索关键字）
		elseif c:match("[%a_]") then
			local wordEnd = line:find("[^%w_]", index) or (#line+1)
			local word = line:sub(index, wordEnd-1)

			if searchKeyword and searchKeyword ~= "" and word:lower():find(searchKeyword:lower()) then
				table.insert(result, '<font color="rgb(255,200,0)">'..word..'</font>')
			elseif keywordSet[word] then
				table.insert(result, '<font color="rgb(255,100,100)">'..word..'</font>')
			else
				table.insert(result, word)
			end

			index = wordEnd

			-- 4. 其他字符
		else
			table.insert(result, c)
			index = index + 1
		end
	end

	return table.concat(result)
end

local function createUI(plugin)
	local info = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float,
		true,   -- 初始可见
		true,   -- 关闭后可再次打开
		960,    -- 默认宽度
		720,    -- 默认高度
		640,    -- 最小宽度
		480     -- 最小高度
	)

	local widget = plugin:CreateDockWidgetPluginGui("SearchFunction", info)
	widget.Title = "Search Function"

	local frame = Instance.new("Frame", widget)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

	-- 标题
	local title = Instance.new("TextLabel", frame)
	title.Size = UDim2.new(1, -40, 0, 30)
	title.Position = UDim2.new(0, 10, 0, 0)
	title.Text = "Search Function"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.SourceSansBold
	title.TextSize = 20
	title.TextXAlignment = Enum.TextXAlignment.Left

	-- 输入框
	local input = Instance.new("TextBox", frame)
	input.Position = UDim2.new(0, 10, 0, 40)
	input.Size = UDim2.new(1, -20, 0, 30)
	input.PlaceholderText = "Enter function name..."
	input.Text = ""
	input.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	input.TextColor3 = Color3.new(1, 1, 1)
	input.ClearTextOnFocus = false

	-- 结果区域
	local results = Instance.new("ScrollingFrame", frame)
	results.Position = UDim2.new(0, 10, 0, 80)
	results.Size = UDim2.new(1, -20, 1, -90)
	results.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	results.ScrollBarThickness = 8
	results.CanvasSize = UDim2.new(0, 0, 0, 0)

	local function escapePattern(text: string): string
		return text:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")
	end

	local function highlightKeyword(line: string, keyword: string): string
		if keyword == "" then return line end
		local safeKeyword = escapePattern(keyword)
		local highlighted = line:gsub(safeKeyword, string.format('<font color="rgb(255,200,0)">%s</font>', keyword))
		return highlighted
	end

	local function search()
		results:ClearAllChildren()
		local funcName = input.Text
		if funcName == "" then return end

		local y = 20
		local count = 0
		
		-- 先创建总数标签（初始为空）
		local totalLabel = Instance.new("TextLabel", results)
		totalLabel.Size = UDim2.new(1, -10, 0, 20)
		totalLabel.Position = UDim2.new(0, 5, 0, 0)
		totalLabel.BackgroundTransparency = 1
		totalLabel.TextColor3 = Color3.new(1, 1, 0)
		totalLabel.Font = Enum.Font.SourceSansBold
		totalLabel.TextSize = 14
		totalLabel.Text = "Searching..."

		for _, obj in ipairs(game:GetDescendants()) do
			if obj:IsA("ModuleScript") or obj:IsA("LocalScript") or obj:IsA("Script") then
				local src = obj.Source
				if not src then continue end
				local lines = {}
				for line in src:gmatch("([^\n]*)\n?") do
					table.insert(lines, line)
				end

				for i, line in ipairs(lines) do
					if line:find(escapePattern(funcName)) then
						count += 1

						-- 结果容器
						local resultFrame = Instance.new("Frame", results)
						resultFrame.Position = UDim2.new(0, 0, 0, y)
						resultFrame.Size = UDim2.new(1, 0, 0, 120)
						resultFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

						-- 点击按钮
						local btn = Instance.new("TextButton", resultFrame)
						btn.Size = UDim2.new(1, 0, 0, 24)
						btn.TextXAlignment = Enum.TextXAlignment.Left
						btn.Text = string.format(" %d. %s : line %d", count, obj:GetFullName(), i)
						btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
						btn.TextColor3 = Color3.new(0.690196, 0.905882, 1)
						btn.Font = Enum.Font.Code
						btn.TextSize = 14
						btn.MouseButton1Click:Connect(function()
							Selection:Set({obj})
							openAtLine(plugin, obj, i)
						end)

						-- 代码预览
						local preview = Instance.new("TextLabel", resultFrame)
						preview.Position = UDim2.new(0, 5, 0, 28)
						preview.Size = UDim2.new(1, -10, 1, -32)
						preview.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
						preview.TextColor3 = Color3.new(1, 1, 1)
						preview.Font = Enum.Font.Code
						preview.TextSize = 14
						preview.TextXAlignment = Enum.TextXAlignment.Left
						preview.TextYAlignment = Enum.TextYAlignment.Top
						preview.TextWrapped = false
						preview.RichText = true

						local context = {}
						for j = math.max(1, i - 2), math.min(#lines, i + 2) do
							local rawLine = tostring(j) .. ": " .. lines[j]
							table.insert(context, highlightCode(rawLine, funcName))
						end
						preview.Text = table.concat(context, "\n")

						-- 双击跳转
						local lastClick = 0
						preview.InputBegan:Connect(function(inputObj)
							if inputObj.UserInputType == Enum.UserInputType.MouseButton1 then
								local now = tick()
								if now - lastClick < 0.3 then
									openAtLine(plugin, obj, i)
								end
								lastClick = now
							end
						end)

						y += resultFrame.Size.Y.Offset + 5
					end
				end
			end
		end

		-- 更新总数显示
		totalLabel.Text = "Total Results: " .. count

		results.CanvasSize = UDim2.new(0, 0, 0, y)
		results.CanvasPosition = Vector2.new(0, 0) -- 自动滚动到顶部
	end

	input.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			search()
		end
	end)

	return widget
end

local WindowInstance = nil

function SearchFunction:Execute(plugin)
	if not WindowInstance then
		WindowInstance = createUI(plugin)
	else
		WindowInstance.Enabled = not WindowInstance.Enabled
	end
end

return SearchFunction
