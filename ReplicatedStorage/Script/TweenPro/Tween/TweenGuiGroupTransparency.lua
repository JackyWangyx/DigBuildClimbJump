local TweenGuiGroupTransparency = {}

local math_lerp = math.lerp

local TransparencyCache = {}

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

function TweenGuiGroupTransparency:GetPartList(target)
	local list = TransparencyCache[target]
	if list then return list end

	list = {}

	for _, obj in ipairs(target:GetDescendants()) do
		local prop = ClassMap[obj.ClassName]
		if not prop then continue end

		local default = obj[prop]
		if default == 1 then continue end

		list[#list + 1] = {
			Part = obj,
			Property = prop,
			Default = default,
		}
	end

	TransparencyCache[target] = list
	return list
end

function TweenGuiGroupTransparency:OnSpawn(tweener)
	tweener._isIn = tweener.From > tweener.To
	TweenGuiGroupTransparency:GetPartList(tweener.Target)
end

function TweenGuiGroupTransparency:OnDeSpawn(tweener)

end

function TweenGuiGroupTransparency:GetValue(tweener, target)
	return nil
end

function TweenGuiGroupTransparency:SetValue(tweener, target, value)
	local list = TweenGuiGroupTransparency:GetPartList(target)
	local isIn = tweener._isIn

	for i = 1, #list do
		local info = list[i]
		local part = info.Part
		local prop = info.Property
		local default = info.Default

		if isIn then
			part[prop] = math_lerp(1, default, 1 - value)
		else
			part[prop] = math_lerp(default, 1, value)
		end
	end
end

return TweenGuiGroupTransparency
