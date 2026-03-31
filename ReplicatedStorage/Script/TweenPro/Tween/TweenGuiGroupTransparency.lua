local TweenGuiGroupTransparency = {}

local TransparencyCache = {}

function TweenGuiGroupTransparency:GetPartList(target)
	local transparencyList = TransparencyCache[target]
	if not transparencyList then
		local childList = target:GetDescendants()
		transparencyList = {}
		for _, obj in ipairs(childList) do
			local info = nil
			if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
				info = {
					Part = obj, 
					Property = "TextTransparency",
					Defalut = obj.TextTransparency or 0,
				}
			elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
				info = {
					Part = obj, 
					Property = "ImageTransparency",
					Defalut = obj.ImageTransparency or 0,
				}
			elseif obj:IsA("Frame") or obj:IsA("ScrollingFrame") or obj:IsA("ViewportFrame") then
				info = { 
					Part = obj, 
					Property = "BackgroundTransparency",
					Default = obj.BackgroundTransparency or 0,
				}
			elseif obj:IsA("UIStroke") then
				info = { 
					Part = obj, 
					Property = "Transparency",
					Default = obj.Transparency or 0,
				}
			end

			if info == nil then continue end
			if info.Default == 1 then continue end
			table.insert(transparencyList, info)
		end	
		
		TransparencyCache[target] = transparencyList
	end
	
	return transparencyList
end

function TweenGuiGroupTransparency:OnSpawn(tweener)
	local target = tweener.Target
	TweenGuiGroupTransparency:GetPartList(target)
end

function TweenGuiGroupTransparency:OnDeSpawn(tweener)

end

function TweenGuiGroupTransparency:GetValue(tweener, target)
	return nil
end

function TweenGuiGroupTransparency:SetValue(tweener, target, value)
	local transparentList = TweenGuiGroupTransparency:GetPartList(target)
	for _, info in ipairs(transparentList) do
		local default = info.Default or 0 -- or info.Part[info.Property]
		if tweener.From > tweener.To then
			-- In : 1 -> 0
			info.Part[info.Property] = math.lerp(1, default, (1 - value))
		else
			-- Out : 0 -> 1
			info.Part[info.Property] = math.lerp(default, 1, value)
		end
	end
end

return TweenGuiGroupTransparency
