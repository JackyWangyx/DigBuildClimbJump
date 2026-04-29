local TweenGuiTransparency = {}

local ClassMap = {
	TextLabel = "TextTransparency",
	TextButton = "TextTransparency",
	TextBox = "TextTransparency",

	ImageLabel = "ImageTransparency",
	ImageButton = "ImageTransparency",

	Frame = "BackgroundTransparency",
	ScrollingFrame = "BackgroundTransparency",
	ViewportFrame = "BackgroundTransparency",

	UIStroke = "Transparency",
}

local function getProperty(target)
	return ClassMap[target.ClassName] or "BackgroundTransparency"
end

function TweenGuiTransparency:GetValue(tweener, target)
	local prop = getProperty(target)
	return target[prop]
end

function TweenGuiTransparency:SetValue(tweener, target, value)
	local prop = getProperty(target)
	target[prop] = value
end

return TweenGuiTransparency