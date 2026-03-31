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

-- cacheChildList
-- 缓存信息根节点的所有子节点列表，提升所有信息重复查找子节点的性能

function UIInfo:SetInfo(itemPart, info)
	if not itemPart then return end
	if not info then return end
	local cacheChildList = itemPart:GetDescendants()
	for key, value in pairs(info) do
		UIInfo:SetValue(itemPart , key, value, cacheChildList)
	end
end

function UIInfo:SetValueByNameImpl(itemPart, infoPartName, func, cacheChildList)
	local infoPartList = Util:GetAllChildByName(itemPart, infoPartName, true, cacheChildList)
	if infoPartList then
		for _, infoPart in ipairs(infoPartList) do
			if infoPart and func then
				func(infoPart)
			end		
		end	
	end
end

function UIInfo:SetValueByTypeImpl(itemPart, partType, infoPartName, func, cacheChildList)
	local infoPartList = Util:GetAllChildByTypeAndName(itemPart, partType, infoPartName, true, cacheChildList)
	if infoPartList then
		for _, infoPart in ipairs(infoPartList) do
			if infoPart and func then
				func(infoPart)
			end	
		end	
	end
end

function UIInfo:SetValue(itemPart, key, value, cacheChildList)
	if not itemPart then return end
	
	-- Info Value
	UIInfo:SetValueByNameImpl(itemPart, "Info_"..key, function(infoPart)
		local show = Util:IsValueValid(value)
		infoPart.Visible = show
	end, cacheChildList)
	
	-- String
	if type(value) == "string" then
		-- Image Asset
		local isAssetID = Util:IsValidAssetID(value)
		if isAssetID then
			UIInfo:SetValueByTypeImpl(itemPart, "ImageLabel", "Image_"..key, function(infoPart)
				infoPart.Image = value
			end, cacheChildList)
		else
			-- Text String Label
			UIInfo:SetValueByTypeImpl(itemPart, "TextLabel", "Text_"..key, function(infoPart)
				infoPart.Text = tostring(value)
			end, cacheChildList)
		end
	end

	-- Number
	if type(value) == "number" then
		-- Text Number Label
		UIInfo:SetValueByTypeImpl(itemPart, "TextLabel", "Text_"..key, function(infoPart)
			infoPart.Text = value
		end,  cacheChildList)

		-- F2
		UIInfo:SetValueByTypeImpl(itemPart, "TextLabel", "Text_"..key.."_F2", function(infoPart)
			infoPart.Text = string.format("%.2f", value)
		end,  cacheChildList)
		
		-- BigNumber
		UIInfo:SetValueByTypeImpl(itemPart, "TextLabel", "Text_"..key.."_BigNumber", function(infoPart)
			infoPart.Text = BigNumber:Format(value)
		end,  cacheChildList)
		
		-- Time
		UIInfo:SetValueByTypeImpl(itemPart, "TextLabel", "Text_"..key.."_Time", function(infoPart)
			infoPart.Text = TimeUtil:AutoFormat(value)
		end,  cacheChildList)

		-- Enum Part
		local enumPartNamePrefix = "Enum_"..key.."_"
		local enumPartName = enumPartNamePrefix..value
		local enumPartList = Util:GetAllChildByNameFuzzy(itemPart, enumPartNamePrefix, true, cacheChildList)
		for _, enumPart in ipairs(enumPartList) do
			if enumPart.Name == enumPartName then
				enumPart.Visible = true
			else
				enumPart.Visible = false
			end
		end
		
		-- Image FillAmount
		UIInfo:SetValueByTypeImpl(itemPart, "ImageLabel", "Image_FillAmount_"..key, function(infoPart)
			local size = infoPart.Size
			infoPart.Size = UDim2.new(value, size.X.Offset, size.Y.Scale, size.Y.Offset)
		end,  cacheChildList)
	end

	-- Boolean
	if type(value) == "boolean" then
		-- Toggle Active
		UIInfo:SetValueByNameImpl(itemPart, "Toggle_"..key.."_True", function(infoPart)
			infoPart.Visible = value
		end,  cacheChildList)
		
		UIInfo:SetValueByNameImpl(itemPart, "Toggle_"..key.."_False", function(infoPart)
			infoPart.Visible = not value
		end,  cacheChildList)
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
