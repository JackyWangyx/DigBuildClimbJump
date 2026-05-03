local TweenGuiColor = {}

local ClassMap = {
	TextLabel = "TextColor3",
	TextButton = "TextColor3",
	TextBox = "TextColor3",

	ImageLabel = "ImageColor3",
	ImageButton = "ImageColor3",

	Frame = "BackgroundColor3",
	ScrollingFrame = "BackgroundColor3",
	ViewportFrame = "BackgroundColor3",
}

local function getProperty(target)
	return ClassMap[target.ClassName]
end

function TweenGuiColor:GetValue(tweener, target)
	local prop = getProperty(target)
	if not prop then return nil end
	return target[prop]
end

function TweenGuiColor:SetValue(tweener, target, value)
	local prop = getProperty(target)
	if not prop then return end
	target[prop] = value
end

return TweenGuiColor