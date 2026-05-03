local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)

local HighlightUtil = {}

function HighlightUtil:HandleLOD(part)
	local highlight = Util:GetChildByType(part, "Highlight")
	if not highlight then return end

	local camera = workspace.CurrentCamera

	local MAX_DISTANCE = 200
	local CHECK_INTERVAL = 0.2
	local FADE_SPEED = 3

	-- 可见状态
	local FILL_VISIBLE = 0.5
	local OUTLINE_VISIBLE = 0

	-- 隐藏状态
	local FILL_HIDDEN = 1
	local OUTLINE_HIDDEN = 1

	-- 当前

	local fillCurrent = 1
	local outlineCurrent = 1

	local fillTarget = 1
	local outlineTarget = 1

	local timer = 0
	local isEnabled = false

	local highlightPart = highlight.Parent

	highlight.Enabled = false
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1

	local connection = UpdatorManager:RenderStepped(function(dt)
		timer += dt
		if timer >= CHECK_INTERVAL then
			timer = 0

			if camera then
				local distance = (camera.CFrame.Position - highlightPart.Position).Magnitude

				if distance <= MAX_DISTANCE then
					fillTarget = FILL_VISIBLE
					outlineTarget = OUTLINE_VISIBLE
				else
					fillTarget = FILL_HIDDEN
					outlineTarget = OUTLINE_HIDDEN
				end
			end
		end

		fillCurrent = fillCurrent + (fillTarget - fillCurrent) * math.clamp(dt * FADE_SPEED, 0, 1)
		outlineCurrent = outlineCurrent + (outlineTarget - outlineCurrent) * math.clamp(dt * FADE_SPEED, 0, 1)

		highlight.FillTransparency = fillCurrent
		highlight.OutlineTransparency = outlineCurrent

		if not isEnabled and outlineCurrent < 0.95 then
			highlight.Enabled = true
			isEnabled = true
		end

		if isEnabled and outlineCurrent > 0.999 then
			highlight.Enabled = false
			isEnabled = false
		end
	end)

	part.Destroying:Connect(function()
		connection:Destroy()
	end)
end

-- HighLight

local HighlightCache = setmetatable({}, { __mode = "k" })

function HighlightUtil:EnableHighlight(target, color, fillTransparency, outlineTransparency)
	if not target then return end
	if HighlightCache[target] and HighlightCache[target].Parent then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.Adornee = target
	highlight.Parent = target

	highlight.OutlineColor = color or Color3.fromRGB(255, 0, 0)
	highlight.FillColor = color or Color3.fromRGB(255, 0, 0)
	highlight.FillTransparency = fillTransparency or 0.75
	highlight.OutlineTransparency = outlineTransparency or 0

	HighlightCache[target] = highlight
end

function HighlightUtil:DisableHighlight(target)
	if not target then return end
	local highlight = HighlightCache[target]
	if highlight then
		highlight:Destroy()
		HighlightCache[target] = nil
	end
end

function HighlightUtil:DisableAllHighlight()
	for target, highlight in pairs(HighlightCache) do
		if highlight then
			highlight:Destroy()
		end
		HighlightCache[target] = nil
	end
end

-- SelectionBox

local SelectionCache = setmetatable({}, { __mode = "k" })

function HighlightUtil:EnableSelectionBox(target, color, lineThickness)
	if not target then return end
	if SelectionCache[target] and SelectionCache[target].Parent then
		return
	end

	local selection = Instance.new("SelectionBox")
	selection.Adornee = target
	selection.Parent = target
	
	selection.SurfaceTransparency = 1
	selection.LineThickness = lineThickness or 0.05
	selection.Color3 = color or Color3.fromRGB(92, 239, 0)
	selection.Visible = true

	SelectionCache[target] = selection
end

-- 关闭 SelectionBox
function HighlightUtil:DisableSelectionBox(target)
	if not target then return end
	local selection = SelectionCache[target]
	if selection then
		selection:Destroy()
		SelectionCache[target] = nil
	end
end

-- 清除所有 SelectionBox
function HighlightUtil:DisableAllSelectionBox()
	for target, selection in pairs(SelectionCache) do
		if selection then
			selection:Destroy()
		end
		SelectionCache[target] = nil
	end
end

return HighlightUtil
