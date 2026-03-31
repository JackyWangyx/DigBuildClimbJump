local ReplicatedUIItem = game.ReplicatedStorage.Prefab:WaitForChild("UIItem")

local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local AttributeUtil = require(game.ReplicatedStorage.ScriptAlias.AttributeUtil)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local UIEffect = require(game.ReplicatedStorage.ScriptAlias.UIEffect)

local UIList = {}

function UIList:ClearChild(uiPart)
	local listRootPart = Util:GetChildByName(uiPart, "ScrollingFrame")
	local frameList = Util:GetAllChildByType(listRootPart, "Frame", false)
	for _, frame in ipairs(frameList) do
		frame:Destroy()
	end
end

local function NaturalSort(a, b)
	local function split(str)
		local segments = {}
		for text, number in string.gmatch(str, "([%a_]*)(%d*)") do
			if text ~= "" then table.insert(segments, text) end
			if number ~= "" then table.insert(segments, tonumber(number)) end
		end
		return segments
	end

	local aParts = split(a.Name)
	local bParts = split(b.Name)

	for i = 1, math.max(#aParts, #bParts) do
		local aVal = aParts[i]
		local bVal = bParts[i]

		if aVal == nil then return true end
		if bVal == nil then return false end

		if type(aVal) == "string" and type(bVal) == "string" then
			if aVal ~= bVal then
				return aVal < bVal
			end
		elseif type(aVal) == "number" and type(bVal) == "number" then
			if aVal ~= bVal then
				return aVal < bVal
			end
		elseif type(aVal) ~= type(bVal) then
			-- 字符串排在数字前面
			return type(aVal) == "string"
		end
	end

	return false
end

function UIList:ForechItem(uiPart, itemPrefabName, requireCount, func)
	local listRootPart = Util:GetChildByName(uiPart, "ScrollingFrame")
	local frameList = Util:GetAllChildByType(listRootPart, "Frame", false)
	table.sort(frameList, NaturalSort)
	for _, frame in ipairs(frameList) do
		frame.Visible = false
	end
	
	local frameCount = #frameList
	local count = frameCount >= requireCount and frameCount or requireCount
	
	if itemPrefabName then
		-- 指定预制，则动态生成列表
		local listItemPrefab = game.ReplicatedStorage.Prefab.UIItem:WaitForChild(itemPrefabName)
		local itemList = {}
		for index = 1, count do
			if index <= frameCount then
				local frame = frameList[index]
				if index <= requireCount then
					-- 复用已经存在的节点
					local item = frame
					func(index, item)

					UIList:RefreshItem(item)
					item.Visible = true
					item.ZIndex = index
					table.insert(itemList, item)
				else
					-- 删除多余的节点
					frame:Destroy()
				end
			else
				if index <= requireCount then
					-- 创建新节点
					local item = listItemPrefab:Clone()
					item.Name = "Item_"..index
					item.Parent = listRootPart
					func(index, item)

					UIList:RefreshItem(item)
					item.Visible = true
					item.ZIndex = index
					table.insert(itemList, item)
				end
			end
		end
		
		return itemList
	else
		-- 未指定预制，则重新处理现有列表
		local itemList = {}
		for index = 1, frameCount do
			if index <= frameCount then
				local frame = frameList[index]
				if index <= requireCount then
					local item = frame
					func(index, item)
					UIList:RefreshItem(item)
					item.Visible = true
					item.ZIndex = index
					table.insert(itemList, item)
				end
			end	
		end
		
		return itemList
	end
end

function UIList:LoadWithData(uiPart, itemPrefabName, configName)
	local dataList = ConfigManager:GetDataList(configName)
	if not dataList then return {} end
	local itemList = UIList:ForechItem(uiPart, itemPrefabName, #dataList, function(index, item)
		local data = dataList[index]
		
		AttributeUtil:Clear(item)
		AttributeUtil:SetData(item, data)
	end)
	
	return itemList
end

function UIList:LoadWithInfo(uiPart, itemPrefabName, infoList)
	if not infoList then return {} end
	local itemList = UIList:ForechItem(uiPart, itemPrefabName, #infoList, function(index, item)
		local info = infoList[index]
		
		AttributeUtil:Clear(item)
		AttributeUtil:SetInfo(item, info)
	end)
	
	return itemList
end

function UIList:LoadWithInfoData(uiPart, itemPrefabName, infoList, configName)
	if not infoList then return {} end
	local dataList = ConfigManager:GetDataList(configName)
	if not dataList then return {} end
	local itemList = UIList:ForechItem(uiPart, itemPrefabName, #infoList, function(index, item)
		local info = infoList[index]
		local data = dataList[info.ID]
		
		AttributeUtil:Clear(item)
		-- Info 中可能包含覆盖计算的 Data 数据，所以先设置 Data 后设置 Info
		AttributeUtil:SetData(item, data)
		AttributeUtil:SetInfo(item, info)
	end)
	
	return itemList
end

function UIList:HandleItemList(itemList, uiListScript, uiItemScriptName)
	if not itemList then return end
	local uiItemScriptFile = Util:GetChildByTypeAndName(game.ReplicatedStorage, "ModuleScript", uiItemScriptName)
	for index, item in ipairs(itemList) do
		local uiItem = require(uiItemScriptFile).new()
		UIInfo:HandleAllButton(item, uiItem, {
			UIListScript = uiListScript,
			UIRoot = item,
			Index = index
		})
	end
end

function UIList:RefreshItem(itemPart)
	for attributeName, attributeValue in pairs(itemPart:GetAttributes()) do
		if Util:IsStrStartWith(attributeName, "Data_") then
			local key = string.gsub(attributeName, "Data_", "")
			local value = attributeValue
			UIInfo:SetValue(itemPart, key, value)
		end
	end
	
	for attributeName, attributeValue in pairs(itemPart:GetAttributes()) do
		if Util:IsStrStartWith(attributeName, "Info_") then
			local key = string.gsub(attributeName, "Info_", "")
			local value = attributeValue
			UIInfo:SetValue(itemPart, key, value)
		end
	end
end

function UIList:HadnlePlayerHeadIconAsync(itemList)
	for index, item in ipairs(itemList) do
		local playerID = AttributeUtil:GetInfoValue(item, "UserID")
		local player = PlayerManager:GetPlayerById(playerID)
		PlayerManager:GetHeadIconAsync(player, function(icon)
			if not item then return end
			UIInfo:SetValue(item, "HeadIcon", icon)
		end)
	end
end

return UIList
