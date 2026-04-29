local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local UIButtonClose = require(game.ReplicatedStorage.ScriptAlias.UIButtonClose)
local UIButtonGamePass = require(game.ReplicatedStorage.ScriptAlias.UIButtonGamePass)
local UIButtonDevelopProduct = require(game.ReplicatedStorage.ScriptAlias.UIButtonDevelopProduct)
local UIButtonNewbiePack = require(game.ReplicatedStorage.ScriptAlias.UIButtonNewbiePack)
local BigNumber = require(game.ReplicatedStorage.ScriptAlias.BigNumber)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local TimeUtil = require(game.ReplicatedStorage.ScriptAlias.TimeUtil)

local UIInfo = {}

local Cache = {}

function UIInfo:GetAllCache()
	return Cache
end

function UIInfo:GetCache(itemPart)
	local cache = Cache[itemPart]
	if not cache then
		cache = {
			InfoPartDic = {},
			TypeInfoPartDic = {},
			KeyDic = {},
			EnumDic = {},
		}
		
		Cache[itemPart] = cache
	end
	
	return cache
end

function UIInfo:ClearCache(itemPart)
	Cache[itemPart] = nil
end

function UIInfo:SetInfo(itemPart, info)
	if not itemPart then return end
	if not info then return end
	local cache = UIInfo:GetCache(itemPart)
	if not cache.ChildList then
		cache.ChildList = itemPart:GetDescendants()
	end

	for key, value in pairs(info) do
		UIInfo:SetValue(itemPart , key, value, cache)
	end
end

function UIInfo:SetValueByNameImpl(itemPart, infoPartName, func, cache)
	if cache then
		local infoPartList = cache.InfoPartDic[infoPartName]
		if not infoPartList then
			infoPartList = Util:GetAllChildByName(itemPart, infoPartName, true, cache.ChildList)
			cache.InfoPartDic[infoPartName] = infoPartList
		end

		for _, infoPart in ipairs(infoPartList) do
			if infoPart and func then
				func(infoPart)
			end		
		end	
	else
		local infoPartList = Util:GetAllChildByName(itemPart, infoPartName, true)
		for _, infoPart in ipairs(infoPartList) do
			if infoPart and func then
				func(infoPart)
			end		
		end	
	end
end

function UIInfo:SetValueByTypeImpl(itemPart, partType, infoPartName, func, cache)
	if cache then
		local infoTypePartList = cache.TypeInfoPartDic[partType]
		if not infoTypePartList then
			infoTypePartList = {}
			cache.TypeInfoPartDic[partType] = infoTypePartList
		end

		local infoPartList = infoTypePartList[infoPartName]
		if not infoPartList then
			infoPartList = Util:GetAllChildByTypeAndName(itemPart, partType, infoPartName, true, cache.ChildList)
			infoTypePartList[infoPartName] = infoPartList
		end

		for _, infoPart in ipairs(infoPartList) do
			if infoPart and func then
				func(infoPart)
			end	
		end	
	else
		local infoPartList = Util:GetAllChildByTypeAndName(itemPart, partType, infoPartName, true)
		for _, infoPart in ipairs(infoPartList) do
			if infoPart and func then
				func(infoPart)
			end	
		end	
	end
end

function UIInfo:GetPartNameByKey(valueType, key, cache)
	local partName = nil
	if cache then
		local typeDic = cache.KeyDic[valueType]
		if not typeDic then
			typeDic = {}
			cache.KeyDic[valueType] = {}
		end
		
		local cachePartName = typeDic[key]
		partName = cachePartName
	end
	
	if not partName then
		if valueType == "Info" then
			partName = "Info_"..key
		elseif valueType == "Image" then
			partName = "Image_"..key
		elseif valueType == "Text" then
			partName = "Text_"..key
		elseif valueType == "TextNumber" then
			partName = "Text_"..key
		elseif valueType == "TextF2" then
			partName = "Text_"..key.."_F2"
		elseif valueType == "TextBigNumber" then
			partName = "Text_"..key.."_BigNumber"
		elseif valueType == "TextTime" then
			partName = "Text_"..key.."_Time"
		elseif valueType == "ImageFillAmount" then
			partName = "Image_FillAmount_" .. key
		elseif valueType == "ImageFillAmountV" then
			partName = "Image_FillAmount_" .. key .. "_V"
		elseif valueType == "ToggleTrue" then
			partName = "Toggle_"..key.."_True"
		elseif valueType == "ToggleFalse" then
			partName = "Toggle_"..key.."_False"
		end
		
		if cache then
			cache.KeyDic[valueType][key] = partName
		end
	end
	
	return partName
end

function UIInfo:GetPartEnumCache(itemPart, key, value)
	local cache = UIInfo:GetCache(itemPart)
	local enumCache = cache.EnumDic[key]
	if not enumCache then
		enumCache = {}
		cache.EnumDic[key] = enumCache
	end
	
	if not enumCache.EnumPrefix then
		local enumPartNamePrefix = "Enum_" .. key .. "_"
		enumCache.EnumPrefix = enumPartNamePrefix
		local enumPartList = Util:GetAllChildByNameFuzzy(itemPart, enumPartNamePrefix, true, cache.ChildList)
		enumCache.PartList = enumPartList
	end
	
	if not enumCache.ValuePartNameDic then
		enumCache.ValuePartNameDic = {}
	end
	
	local enumPartName = enumCache.ValuePartNameDic[tostring(value)]
	if not enumPartName then
		enumPartName = enumCache.EnumPrefix .. value
		enumCache.ValuePartNameDic[tostring(value)] = enumPartName
	end
	
	return enumCache
end

function UIInfo:SetValue(itemPart, key, value, cache)
	if not itemPart then return end
	if not cache then
		cache = UIInfo:GetCache(itemPart)
	end
	
	-- Info Value
	local partName = UIInfo:GetPartNameByKey("Info", key, cache)
	UIInfo:SetValueByNameImpl(itemPart, partName, function(infoPart)
		local show = Util:IsValueValid(value)
		infoPart.Visible = show
	end, cache)
	
	local valueType = typeof(value)
	-- String
	if valueType == "string" then
		-- Image Asset
		local isAssetID = Util:IsValidAssetID(value)
		if isAssetID then
			partName = UIInfo:GetPartNameByKey("Image", key, cache)
			UIInfo:SetValueByTypeImpl(itemPart, "ImageLabel", partName, function(infoPart)
				infoPart.Image = value
			end, cache)
		else
			-- Text String Label
			partName = UIInfo:GetPartNameByKey("Text", key, cache)
			UIInfo:SetValueByTypeImpl(itemPart, "TextLabel", partName, function(infoPart)
				infoPart.Text = tostring(value)
			end, cache)
		end
	end

	-- Number
	if valueType == "number" then
		-- Text Number Label
		partName = UIInfo:GetPartNameByKey("TextNumber", key, cache)
		UIInfo:SetValueByTypeImpl(itemPart, "TextLabel", partName, function(infoPart)
			infoPart.Text = value
		end,  cache)

		-- F2
		partName = UIInfo:GetPartNameByKey("TextF2", key, cache)
		UIInfo:SetValueByTypeImpl(itemPart, "TextLabel", partName, function(infoPart)
			infoPart.Text = string.format("%.2f", value)
		end,  cache)
		
		-- BigNumber
		partName =  UIInfo:GetPartNameByKey("TextBigNumber", key, cache)
		UIInfo:SetValueByTypeImpl(itemPart, "TextLabel", partName, function(infoPart)
			infoPart.Text = BigNumber:Format(value)
		end,  cache)
		
		-- Time
		partName =  UIInfo:GetPartNameByKey("TextTime", key, cache)
		UIInfo:SetValueByTypeImpl(itemPart, "TextLabel", partName, function(infoPart)
			infoPart.Text = TimeUtil:AutoFormat(value)
		end,  cache)

		-- Image FillAmount
		partName = UIInfo:GetPartNameByKey("ImageFillAmount", key, cache)
		UIInfo:SetValueByTypeImpl(itemPart, "ImageLabel", partName, function(infoPart)
			local size = infoPart.Size
			infoPart.Size = UDim2.new(value, size.X.Offset, size.Y.Scale, size.Y.Offset)
		end, cache)
		
		partName = UIInfo:GetPartNameByKey("ImageFillAmountV", key, cache)
		UIInfo:SetValueByTypeImpl(itemPart, "ImageLabel", partName, function(infoPart)
			local size = infoPart.Size
			infoPart.Size = UDim2.new(size.X.Scale, size.X.Offset, value, size.Y.Offset)
		end, cache)
	
		-- Enum Part
		local enumCache = UIInfo:GetPartEnumCache(itemPart, key, value)
		local enumPartName = enumCache.ValuePartNameDic[tostring(value)]
		for _, enumPart in ipairs(enumCache.PartList) do
			if enumPart.Name == enumPartName then
				enumPart.Visible = true
			else
				enumPart.Visible = false
			end
		end
		
		-- Enum Part
		--local enumPartNamePrefix = "Enum_"..key.."_"
		--local enumPartName = enumPartNamePrefix..value
		--local enumPartList = Util:GetAllChildByNameFuzzy(itemPart, enumPartNamePrefix, true, cache.ChildList)
		--for _, enumPart in ipairs(enumPartList) do
		--	if enumPart.Name == enumPartName then
		--		enumPart.Visible = true
		--	else
		--		enumPart.Visible = false
		--	end
		--end
	end

	-- Boolean
	if valueType == "boolean" then
		-- Toggle Active
		partName = UIInfo:GetPartNameByKey("ToggleTrue", key, cache)
		UIInfo:SetValueByNameImpl(itemPart, partName, function(infoPart)
			infoPart.Visible = value
		end,  cache)
		
		partName = UIInfo:GetPartNameByKey("ToggleFalse", key, cache)
		UIInfo:SetValueByNameImpl(itemPart, partName, function(infoPart)
			infoPart.Visible = not value
		end,  cache)
	end
end

function UIInfo:HandleAllButton(uiRoot, uiScript, param, cacheChildList)
	if not uiRoot then return end
	local allButtonList = Util:GetAllChildByType(uiRoot, "GuiButton", true, cacheChildList)
	if not allButtonList then return end

	for _, button in ipairs(allButtonList) do
		-- 处理特殊按钮
		local buttonName = button.Name
		if buttonName == "Button_Close" then
			UIButtonClose:Handle(button)
			continue
		end
		
		-- IAP GamePass
		
		if string.match(buttonName, "^Button_.+_GamePass$") ~= nil then
			UIButtonGamePass:Handle(button)
			continue
		end
		
		-- IAP DevelopProduct
		if string.match(buttonName, "^Button_.+_DevelopProduct$") ~= nil then
			UIButtonDevelopProduct:Handle(button)
			continue
		end
		
		-- IAP NewbiePack
		if string.match(buttonName, "^Button_.+_NewbiePack$") ~= nil then
			UIButtonNewbiePack:Handle(button)
			continue
		end
		
		-- 处理通用按钮，自动绑定同名函数
		if Util:IsStrStartWith(buttonName, "Button_") then
			local func = uiScript[buttonName]
			UIButton:Handle(button, func, param)
			continue
		end
		
		-- 处理其他按钮，仅绑定动画
		local buttonEventList = UIButton.ConnectionCache[button] 
		if not buttonEventList or #buttonEventList == 0 then
			UIButton:HandleAnimation(button)
		end
	end
end

return UIInfo
