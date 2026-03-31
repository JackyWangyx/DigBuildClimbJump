local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ObjectPool = require(game.ReplicatedStorage.ScriptAlias.ObjectPool)
local TweenFlyUtil = {}

-- ========================================================
-- 1. 辅助函数
-- ========================================================
-- 依然保留屏幕缩放计算，仅用于控制“爆炸半径”，保证在不同屏幕上炸开的距离合适
local function getScreenScale()
	local camera = Workspace.CurrentCamera
	if not camera then return 1 end
	local baseHeight = 1080
	local currentHeight = camera.ViewportSize.Y
	return math.max(0.4, currentHeight / baseHeight)
end

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function screenToParentOffset(screenPos: Vector2, parent: GuiObject)
	if not parent then return screenPos end
	local parentAbs = parent.AbsolutePosition
	return screenPos - parentAbs
end

local function worldToScreen(worldPos: Vector3)
	local cam = Workspace.CurrentCamera
	local v3 = cam:WorldToViewportPoint(worldPos)
	return Vector2.new(v3.X, v3.Y)
end

local function makeBezierInParent(fromScreen: Vector2, toScreen: Vector2, parent: GuiObject)
	local from = screenToParentOffset(fromScreen, parent)
	local to = screenToParentOffset(toScreen, parent)
	local distance = (to - from).Magnitude
	local scale = getScreenScale()
	local curveH = math.clamp(distance / 2.5, 50 * scale, 300 * scale)
	local randomX = math.random(-30 * scale, 30 * scale)
	local mid = (from + to) / 2 + Vector2.new(randomX, -curveH)
	return function(t)
		local u = 1 - t
		local pos = (u*u)*from + 2*u*t*mid + (t*t)*to
		return pos
	end
end

local function randomSpawnInCenter(container: GuiObject)
	if not container then return Vector2.zero end
	local screenSize = container.AbsoluteSize
	local screenPos = container.AbsolutePosition
	local minX = screenPos.X + screenSize.X * 0.4
	local maxX = screenPos.X + screenSize.X * 0.6
	local minY = screenPos.Y + screenSize.Y * 0.4
	local maxY = screenPos.Y + screenSize.Y * 0.6
	return Vector2.new(math.random(minX, maxX), math.random(minY, maxY))
end

-- ========================================================
-- 2. 核心功能
-- ========================================================
function TweenFlyUtil:UIFlyToTarget(prefab, target, value, opts)
	opts = opts or {}
	local scaleFactor = getScreenScale() -- 仅用于计算爆炸距离
	local container = (opts.Container and opts.Container:IsA("GuiObject")) and opts.Container or prefab.Parent
	if not container or not container:IsA("GuiObject") then
		container = target.Parent
	end
	local flyMode = opts.FlyMode or "Multiple"
	local showText = (opts.ShowText ~= nil) and opts.ShowText or (flyMode == "Single")
	local randRotate = opts.RandRotate
	if randRotate == nil then
		if flyMode == "Single" then
			randRotate = false
		elseif flyMode == "Multiple" then
			randRotate = true
		else
			randRotate = false
		end
	end
	
	local particleCount
	if flyMode == "Single" then
		particleCount = 10
	else
		particleCount = 10
		if type(value) == "number" then
			if value < 10 then
				particleCount = value
			else
				particleCount = math.random(20, 30)
			end
		end
	end
	local startScreenCenter
	if opts.WorldPart then
		startScreenCenter = worldToScreen(opts.WorldPart.Position)
	elseif opts.WorldPosition then
		startScreenCenter = worldToScreen(opts.WorldPosition)
	else
		startScreenCenter = randomSpawnInCenter(container)
	end
	local completedCount = 0
	local uiInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
	for i = 1, particleCount do
		task.spawn(function()
			-- 1. 克隆 (自动继承你在属性面板里设置好的 Size)
			local particle = ObjectPool:Spawn(prefab)
			if showText then
				uiInfo:SetInfo(particle, { Value = value })
			end
			
			particle.Name = "EffectCoin"
			particle.Parent = container
			particle.Visible = true
			particle.BackgroundTransparency = 1
			particle.AnchorPoint = Vector2.new(0.5, 0.5)
			-- 确保层级正确
			pcall(function() particle.ZIndex = (target.ZIndex or 1) + 10 end)
			-- 2. 设置初始位置
			local startOffset = screenToParentOffset(startScreenCenter, container)
			particle.Position = UDim2.fromOffset(startOffset.X, startOffset.Y)
			-- 3. 使用 UIScale 控制缩放动画
			local uiScale = particle:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", particle)
			uiScale.Scale = 0 -- 初始不可见
			-- ------------------------------------------------
			-- 阶段 1：爆炸 (Explosion) 或直接出现
			-- ------------------------------------------------
			if flyMode == "Multiple" then
				local angle = math.random() * math.pi * 2
				-- 爆炸半径依然需要适配屏幕大小，否则在手机上会炸太远
				local minRad = 160 * scaleFactor
				local maxRad = 400 * scaleFactor
				local radius = math.random(minRad, maxRad)
				local offsetX = math.cos(angle) * radius
				local offsetY = math.sin(angle) * radius
				local explodePos = UDim2.fromOffset(startOffset.X + offsetX, startOffset.Y + offsetY)
				local explodeTime = 0.4
				local rotationTarget = randRotate and math.random(-180, 180) or 0
				local explodeTween = TweenService:Create(particle, TweenInfo.new(explodeTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Position = explodePos,
					Rotation = rotationTarget
				})
				-- 【动画】Scale 从 0 变到 1
				-- 这里的 1 代表“还原为 Template 的原始大小”
				local appearTween = TweenService:Create(uiScale, TweenInfo.new(explodeTime * 0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Scale = 2.0
				})
				explodeTween:Play()
				appearTween:Play()
				task.wait(0.3 + math.random() * 0.2)
			else
				-- 单元素模式：直接出现，无爆炸
				uiScale.Scale = 1
				local initialRotation = randRotate and math.random(-180, 180) or 0
				particle.Rotation = initialRotation
			end
			if not particle.Parent then return end
			-- ------------------------------------------------
			-- 阶段 2：停顿与飞行
			-- ------------------------------------------------
			local tgtAbs = target.AbsolutePosition
			local tgtCtr = Vector2.new(tgtAbs.X + target.AbsoluteSize.X / 2, tgtAbs.Y + target.AbsoluteSize.Y / 2)
			local currAbs = particle.AbsolutePosition
			local currCtr = Vector2.new(currAbs.X + particle.AbsoluteSize.X/2, currAbs.Y + particle.AbsoluteSize.Y/2)
			local bezierFunc = makeBezierInParent(currCtr, tgtCtr, container)
			local tVal = Instance.new("NumberValue")
			tVal.Value = 0
			local conn
			conn = tVal.Changed:Connect(function(t)
				if not particle.Parent then
					conn:Disconnect()
					return
				end
				local p = bezierFunc(t)
				particle.Position = UDim2.fromOffset(p.X, p.Y)
				particle.Rotation = lerp(particle.Rotation, 0, t)
			end)
			local flyTime = 0.6
			local flyTween = TweenService:Create(tVal, TweenInfo.new(flyTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Value = 1 })
			-- 【动画】Scale 从 1 变到 0.3 (飞入变小)
			local shrinkTween = TweenService:Create(uiScale, TweenInfo.new(flyTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.3 })
			flyTween:Play()
			shrinkTween:Play()
			flyTween.Completed:Connect(function()
				if tVal then tVal:Destroy() end
				ObjectPool:DeSpawn(particle)
				completedCount = completedCount + 1
				if completedCount == particleCount and showText and type(value) == "number" then
					-- 创建浮动文本
					local textLabel = Instance.new("TextLabel")
					textLabel.Name = "FlyText"
					textLabel.Parent = container
					local textOffset = screenToParentOffset(tgtCtr, container)
					textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
					textLabel.Position = UDim2.fromOffset(textOffset.X, textOffset.Y)
					textLabel.Size = UDim2.new(0, 120, 0, 60)
					textLabel.BackgroundTransparency = 1
					textLabel.Text = "+" .. value
					textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
					textLabel.TextScaled = true
					textLabel.Font = Enum.Font.GothamBold
					textLabel.TextStrokeTransparency = 0
					textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
					local textUI = textLabel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", textLabel)
					textUI.Scale = 0
					local appearText = TweenService:Create(textUI, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
					appearText:Play()
					local textInfo = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					local textMove = TweenService:Create(textLabel, textInfo, {Position = UDim2.fromOffset(textOffset.X, textOffset.Y - 80)})
					local textFade = TweenService:Create(textLabel, textInfo, {TextTransparency = 1})
					local scaleDown = TweenService:Create(textUI, textInfo, {Scale = 0.8})
					textMove:Play()
					textFade:Play()
					scaleDown:Play()
					textMove.Completed:Connect(function()
						textLabel:Destroy()
					end)
				end
				if math.random() > 0.7 then
					local ts = target:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", target)
					local punchIn = TweenService:Create(ts, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1.2})
					punchIn:Play()
					punchIn.Completed:Connect(function()
						TweenService:Create(ts, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 1}):Play()
					end)
				end
			end)
		end)
		if i % 5 == 0 then task.wait() end
	end
	return nil
end

return TweenFlyUtil