local TweenGuiColor = {}

function TweenGuiColor:GetValue(tweener, target)
	if target:IsA("TextLabel") or target:IsA("TextButton") then
		return target.TextColor3
	elseif target:IsA("ImageLabel") or target:IsA("ImageButton") then
		return target.ImageColor3
	else
		return target.BackgroundColor3
	end
end

function TweenGuiColor:SetValue(tweener, target, value)
	if target:IsA("TextLabel") or target:IsA("TextButton") then
		target.TextColor3 = value
	elseif target:IsA("ImageLabel") or target:IsA("ImageButton") then
		target.ImageColor3 = value
	else
		target.BackgroundColor3 = value
	end
end

return TweenGuiColor