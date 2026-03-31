local HighlightUtil = {}

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
