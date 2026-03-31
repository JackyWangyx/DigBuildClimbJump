local TweenGuiTransparency = {}

function TweenGuiTransparency:GetValue(tweener, target)
	if target:IsA("TextLabel") or target:IsA("TextButton") then
		return target.TextTransparency
	elseif target:IsA("ImageLabel") or target:IsA("ImageButton") then
		return target.ImageTransparency
	else
		return target.BackgroundTransparency
	end
end

function TweenGuiTransparency:SetValue(tweener, target, value)
	if target:IsA("TextLabel") or target:IsA("TextButton") then
		target.TextTransparency = value
	elseif target:IsA("ImageLabel") or target:IsA("ImageButton") then
		target.ImageTransparency = value
	else
		target.BackgroundTransparency = value
	end
end

return TweenGuiTransparency
