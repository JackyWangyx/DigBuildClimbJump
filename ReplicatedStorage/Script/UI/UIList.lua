local ReplicatedUIItem = game.ReplicatedStorage.Prefab:WaitForChild("UIItem")

local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local ObjectInfo = require(game.ReplicatedStorage.ScriptAlias.ObjectInfo)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local UIEffect = require(game.ReplicatedStorage.ScriptAlias.UIEffect)
local ResourcesManager = require(game.ReplicatedStorage.ScriptAlias.ResourcesManager)
local UIIndexManager = require(game.ReplicatedStorage.ScriptAlias.UIIndexManager)

local UIList = {}

local string_gmatch = string.gmatch
local string_gsub = string.gsub
local string_sub = string.sub
local table_insert = table.insert
local table_sort = table.sort
local math_max = math.max

function UIList:ClearChild(uiPart)
	local listRoot = UIIndexManager:GetChildByName(uiPart, "ScrollingFrame")
	if not listRoot then
		listRoot = Util:GetChildByName(uiPart, "ScrollingFrame", true)
	end
	
	local itemList = listRoot:GetChildren()
	for index = 1, #itemList do
		local item = itemList[index]
		if item:IsA("Frame") then
			item:Destroy()
		end
	end
end

local function BuildSortKey(name)
	local segments = {}
	for text, number in string_gmatch(name, "([%a_]*)(%d*)") do
		if text ~= "" then table_insert(segments, text) end
		if number ~= "" then table_insert(segments, tonumber(number)) end
	end
	return segments
end

local function NaturalSort(list)
	local mapped = {}

	for index = 1, #list do
		local obj = list[index]
		mapped[index] = {
			obj = obj,
			key = BuildSortKey(obj.Name)
		}
	end

	table_sort(mapped, function(a, b)
		local aParts = a.key
		local bParts = b.key

		for i = 1, math_max(#aParts, #bParts) do
			local aVal = aParts[i]
			local bVal = bParts[i]

			if aVal == nil then return true end
			if bVal == nil then return false end

			if aVal ~= bVal then
				return aVal < bVal
			end
		end

		return false
	end)

	for i = 1, #mapped do
		list[i] = mapped[i].obj
	end
end

function UIList:ForechItem(uiPart, itemPrefabName, requireCount, func)
	-- 有些界面下包含多个同名，缓存有问题
	local listRoot = UIIndexManager:GetChildByName(uiPart, "ScrollingFrame")
	if not listRoot then
		listRoot = Util:GetChildByName(uiPart, "ScrollingFrame", true)
	end
	
	local frames = Util:GetAllChildByType(listRoot, "Frame", false)
	NaturalSort(frames)

	local prefab
	if itemPrefabName then
		prefab = ReplicatedUIItem:FindFirstChild(itemPrefabName)
		if not prefab then
			warn("[UIList] Item Prefab Not Found!", itemPrefabName)
			return
		end
	end

	local itemList = {}

	-- 1. 复用 or 创建
	for i = 1, requireCount do
		local item = frames[i]
		if not item then
			item = prefab:Clone()
			item.Name = "Item_" .. i
			item.Parent = listRoot
		end

		func(i, item)

		UIList:RefreshItem(item)
		item.Visible = true
		item.ZIndex = i

		itemList[i] = item
	end

	-- 2. 删除多余
	for i = requireCount + 1, #frames do
		frames[i]:Destroy()
	end

	return itemList
end

function UIList:LoadWithData(uiPart, itemPrefabName, configName, resort)
	local dataList = ConfigManager:GetDataList(configName)
	if not dataList then return {} end
	local itemList = UIList:ForechItem(uiPart, itemPrefabName, #dataList, function(index, item)
		local data = dataList[index]
		
		ObjectInfo:Clear(item)
		ObjectInfo:SetData(item, data)
	end)
	
	return itemList
end

function UIList:LoadWithInfo(uiPart, itemPrefabName, infoList, resort)
	if not infoList then return {} end
	local itemList = UIList:ForechItem(uiPart, itemPrefabName, #infoList, function(index, item)
		local info = infoList[index]
		
		ObjectInfo:Clear(item)
		ObjectInfo:SetInfo(item, info)
	end)
	
	return itemList
end

function UIList:LoadWithInfoData(uiPart, itemPrefabName, infoList, configName, resort)
	if not infoList then return {} end
	local dataList = ConfigManager:GetDataList(configName)
	if not dataList then return {} end
	local itemList = UIList:ForechItem(uiPart, itemPrefabName, #infoList, function(index, item)
		local info = infoList[index]
		local data = dataList[info.ID]
		
		ObjectInfo:Clear(item)
		-- Info 中可能包含覆盖计算的 Data 数据，所以先设置 Data 后设置 Info
		ObjectInfo:SetData(item, data)
		ObjectInfo:SetInfo(item, info)
	end)
	
	return itemList
end

function UIList:HandleItemList(itemList, uiListScript, uiItemScriptName)
	if not itemList then return end
	local uiItemScriptFile = ResourcesManager:GetScript(uiItemScriptName)
	local uiItemScript = require(uiItemScriptFile)
	for index = 1, #itemList do
		local item = itemList[index]
		local uiItem = uiItemScript.new()
		UIInfo:HandleAllButton(item, uiItem, {
			UIListScript = uiListScript,
			UIRoot = item,
			Index = index,
		}, true)
	end
end

function UIList:RefreshItem(itemPart)
	local data = ObjectInfo:GetData(itemPart)
	UIInfo:SetInfo(itemPart, data)
	local info = ObjectInfo:GetInfo(itemPart)
	UIInfo:SetInfo(itemPart, info)
end

function UIList:HadnlePlayerHeadIconAsync(itemList)
	for index = 1, #itemList do
		local item = itemList[index]
		local playerID = ObjectInfo:GetInfoValue(item, "UserID")
		local player = PlayerManager:GetPlayerById(playerID)
		PlayerManager:GetHeadIconAsync(player, function(icon)
			if not item then return end
			local info = {
				HeadIcon = icon
			}
			
			UIInfo:SetInfo(item, info)
		end)
	end
end

return UIList
