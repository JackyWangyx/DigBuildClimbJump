local Workspace = game.Workspace
local Players = game.Players
local ReplicatedStorage = game.ReplicatedStorage
local ResourcesManager = require(game.ReplicatedStorage.ScriptAlias.ResourcesManager)

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Util = {}

local table_insert = table.insert
local table_remove = table.remove
local table_clone = table.clone
local table_sort = table.sort
local table_clear = table.clear
local math_min = math.min
local math_max = math.max
local math_random = math.random
local math_floor = math.floor
local math_ceil = math.ceil
local math_abs = math.abs
local math_pow = math.pow
local math_sqrt = math.sqrt
local math_round = math.round
local math_rad = math.rad
local math_deg = math.deg
local string_sub = string.sub
local string_match = string.match
local string_format = string.format
local string_gmatch = string.gmatch
local string_find = string.find
local Vector3_new = Vector3.new
local Vector2_new = Vector2.new
local CFrame_new = CFrame.new

------------------------------------------------------------------------------------
-- Valid

function Util:IsValueValid(value)
	if value == nil or value == "" or value == "nil" or value == "NIL" or value == 0 then
		return false
	end

	return true
end

------------------------------------------------------------------------------------
-- Error

function Util:HandleError(err)
	local trace = debug.traceback(err, 2)
	local formattedTrace = {}

	print("🔴 Stack Begin")
	warn(err)
	for line in trace:gmatch("[^\n]+") do
		local scriptName, lineNum = line:match("([^:]+):(%d+)") 
		if scriptName and lineNum then
			table_insert(formattedTrace,  "Script '" .. scriptName .. "': Line " .. lineNum)
		else
			table_insert(formattedTrace, line) -- 其他非代码定位行也保留
		end
	end

	for _, log in ipairs(formattedTrace) do
		warn(log)
	end
	print("🔴 Stack End")
	return trace
end

-- Test
function Util:Test(name, func)
	local startTime = tick()
	func()
	local endTime = tick()
	local time = math_round((endTime - startTime) * 1000)
	print("[🛠️ Test] "..name.." : "..time.." ms")
end

-- Roblox Part

function Util:BindPartEnabled(part, onEnable, onDisable)
	return Util:BindPartProperty(part, "Enabled", function(value)
		if value then 
			onEnable() 
		else 
			onDisable() 
		end
	end)
end

function Util:BindPartVisible(part, onEnable, onDisable)
	return Util:BindPartProperty(part, "Visible", function(value)
		if value then 
			onEnable() 
		else 
			onDisable() 
		end
	end)
end

function Util:BindPartProperty(part, propertyName, func)
	if not part or not part:IsA("Instance") or part[propertyName] == nil then 
		return nil 
	end
	
	local initialValue = part[propertyName]
	func(initialValue)
	
	local connection = part:GetPropertyChangedSignal(propertyName):Connect(function()
		func(part[propertyName])
	end)
	
	return connection
end

------------------------------------------------------------------------------------
-- Load

function Util:LoadPrefab(path)
	return ResourcesManager:Load(path)
end

function Util:RequireWaitForChild(root, childName, timeout)
	timeout = timeout or 10
	local startTime = tick()
	local object = root:WaitForChild(childName, timeout)
	if not object then
		warn("Wait child timeout: " .. childName .. " at " .. root.Name)
	end
	
	return object
end

------------------------------------------------------------------------------------
-- Get Child / Parent

function Util:GetParentByType(part, typeName)
	local current = part.Parent
	while current do
		if current:IsA(typeName) then
			return current
		end
		current = current.Parent
	end
	return nil
end

function Util:GetParentByName(part, name)
	local current = part.Parent
	while current do
		if current.Name == name then
			return current
		end
		current = current.Parent
	end
	return nil
end

function Util:GetChildByType(part, typeName, isRecursive)
	isRecursive = isRecursive == nil or isRecursive
	local result = nil
	Util:ForEachChild(part, function(child)
		if child:IsA(typeName) then
			result = child
			return true
		end
	end, isRecursive, true)
	return result
end

function Util:GetAllChildByType(part, typeName, isRecursive)
	isRecursive = isRecursive == nil or isRecursive
	local result = {}
	Util:ForEachChild(part, function(child)
		if child:IsA(typeName) then
			table_insert(result, child)
		end
	end, isRecursive, false)
	
	return result
end

function Util:GetChildByTypeAndName(part, typeName, name, isRecursive)
	isRecursive = isRecursive == nil or isRecursive
	local result = nil
	Util:ForEachChild(part, function(child)
		if child:IsA(typeName) and child.Name == name then
			result = child
			return true
		end
	end, isRecursive, true)
	return result
end

function Util:GetAllChildByTypeAndName(part, typeName, name, isRecursive)
	local result = {}
	Util:ForEachChild(part, function(child)
		if child:IsA(typeName) and child.Name == name then
			table_insert(result, child)
		end
	end, isRecursive, true)
	return result
end

function Util:GetChildByName(part, name, isRecursive)
	local result = nil
	Util:ForEachChild(part, function(child)
		if child.Name == name then
			result = child
			return true
		end
	end, isRecursive, true)
	return result
end

function Util:GetAllChildByName(part, name, isRecursive)
	isRecursive = isRecursive == nil or isRecursive
	local result ={}
	Util:ForEachChild(part, function(child)
		if child.Name == name then
			table_insert(result, child)
		end
	end, isRecursive, true)
	return result
end

function Util:GetChildByNameFuzzy(part, name, isRecursive)
	local result = nil
	Util:ForEachChild(part, function(child)
		if string_find(child.Name, name) then
			result = child
			return true
		end
	end, isRecursive, true)
	return result
end

function Util:GetAllChildByNameFuzzy(part, name, isRecursive)
	local result = {}
	Util:ForEachChild(part, function(child)
		if string_find(child.Name, name) then
			table_insert(result, child)
		end
	end, isRecursive, false)
	return result
end

function Util:ForEachChild(root, func, isRecursive, onlyFirst)
	if not root then return end

	isRecursive = isRecursive ~= false
	local function traverse(node)
		local childList = node:GetChildren()
		for index = 1, #childList do
			local child = childList[index]
			local result = func(child)
			if onlyFirst and result then
				return true
			end

			if isRecursive then
				if traverse(child) then
					return true
				end
			end
		end
	end

	traverse(root)
end

function Util:DestroyAllChild(part)
	for _, child in ipairs(part:GetChildren()) do
		child:Destroy()
	end
end

------------------------------------------------------------------------------------
-- Part

function Util:HandleWorkspaceState(instance, onAdded, onRemoved)
	if not instance then return end

	local inWorkspace = instance:IsDescendantOf(workspace)

	if inWorkspace then
		if onAdded then onAdded(instance) end
	else
		if onRemoved then onRemoved(instance) end
	end

	local connection
	connection = instance.AncestryChanged:Connect(function()
		if not instance.Parent then
			connection:Disconnect()
			return
		end

		local nowInWorkspace = instance:IsDescendantOf(workspace)

		if inWorkspace ~= nowInWorkspace then
			inWorkspace = nowInWorkspace

			if nowInWorkspace then
				if onAdded then onAdded(instance) end
			else
				if onRemoved then onRemoved(instance) end
			end
		end
	end)

	return connection
end

------------------------------------------------------------------------------------
-- Time / Date

function Util:GetDateStr()
	local str = os.date("%Y-%m-%d %H:%M:%S")
	return str
end

------------------------------------------------------------------------------------
-- Float

function Util:RoundFloat(num, decimals)
	local factor = 10 ^ decimals
	return math_floor(num * factor + 0.5) / factor
	--return tonumber(string.format("%." .. decimals .. "f", num))
end

------------------------------------------------------------------------------------
-- Vector3

function Util:RoundVector3(vec, decimals)
	return Vector3_new(
		Util:RoundFloat(vec.X, decimals),
		Util:RoundFloat(vec.Y, decimals),
		Util:RoundFloat(vec.Z, decimals)
	)
end

function Util:Vector3Multiply(vector1, vector2)
	return Vector3_new(vector1.X * vector2.X, vector1.Y * vector2.Y, vector1.Z * vector2.Z)
end

------------------------------------------------------------------------------------
-- String

function Util:IsStrEmpty(str)
	if str == nil or str == "" or str == "nil" or str == "null" or str == "NIL" or str == "NULL" then
		return true
	end
	return false
end

function Util:IsValidAssetID(str)
	local c1 = string_sub(str, 1, 13) == "rbxassetid://"
	if c1 then return true end
	local c2 = string_sub(str, 1, 11) == "rbxthumb://"
	if c2 then return true end
	return false
end

function Util:IsStrStartWith(str, startValue)
	if not str then
		return false
	end
	if #str < #startValue then
		return false
	end
	return str:sub(1, #startValue) == startValue
end

function Util:IsStrEndWith(str, endValue)
	if not str then
		return false
	end
	if #str < #endValue then
		return false
	end
	return str:sub(-#endValue) == endValue
end

function Util:FormatProbability(probability)
	local result = string_format("%.3f", probability * 100)
	result = result:gsub("0+$", "") -- 去掉末尾的零
	result = result:gsub("%.$", "") -- 小数点后面没数字则去掉小数点
	result = result.."%"
	return result
end

------------------------------------------------------------------------------------
-- List

function Util:IsListEmpty(target)
	if target == nil then return true end
	if next(target) == nil then return true end
	return false
end

function Util:ListContainsWithCondition(array, condition)
	if not array then return false end
	for index = 1, #array do
		local item = array[index]
		if condition(item) then
			return true
		end
	end
	return false
end

function Util:ListContains(array, value)
	if not array then return false end
	for index = 1, #array do
		local item = array[index]
		if item == value then
			return true
		end
	end
	return false
end

function Util:ListSum(array, valueGetter)
	if not array then return 0 end
	local count = 0
	for index = 1, #array do
		local item = array[index]
		count = count + valueGetter(item)
	end
	return count
end

function Util:ListCount(array, condition)
	if not array then return 0 end
	if not condition then return #array end
	local count = 0
	for index = 1, #array do
		local item = array[index]
		if condition(item) then
			count += 1
		end
	end
	return count
end

function Util:ListRemoveWithCondition(array, condition)
	if not array then return false end
	local result = false
	for i = #array, 1, -1 do
		local item = array[i]
		if condition(item) then
			table_remove(array, i)
			result = true
		end
	end
	
	return result
end

function Util:ListRemove(array, value)
	if not array then return false end

	local count = 0
	for index = 1, #array do
		local item = array[index]
		if item == value then
			count += 1
		end
	end

	-- 少量删除 → 用 remove
	if count <= 2 then
		local removed = false
		for i = #array, 1, -1 do
			if array[i] == value then
				table_remove(array, i)
				removed = true
			end
		end
		return removed
	end

	-- 大量删除 → rebuild
	local new = {}
	local removed = false

	for index = 1, #array do
		local item = array[index]
		if item ~= value then
			new[#new + 1] = item
		else
			removed = true
		end
	end

	table_clear(array)
	for i = 1, #new do
		array[i] = new[i]
	end

	return removed
end

function Util:ListRandom(array, count)
	count = count or 1
	if not array or #array == 0 then return nil end

	local pool = table_clone(array)

	-- Fisher-Yates 洗牌
	for i = #pool, 2, -1 do
		local j = math_random(i)
		pool[i], pool[j] = pool[j], pool[i]
	end

	if count == 1 then
		return pool[1]
	end

	local result = {}
	for i = 1, math_min(count, #pool) do
		result[i] = pool[i]
	end

	return result
end

-- 排序
-- 每个比较器获取元素的某个属性，正值为升序，负值为降序
	--infoList = Util:ListSort(infoList, {
	--	function(info) return -info.Rarity end,
	--	function(info) return -info.Value1 end,
	--})
	
function Util:ListSort(array, compareItemGetters)
	if not array then return array end
	local comparors = Util:CreateSortComparers(compareItemGetters)
	table_sort(array, comparors)
	return array
end

function Util:ListSortByPartName(partList)
	table_sort(partList, function(a, b)
		local function split(str)
			local segments = {}
			for text, number in string_gmatch(str, "([%a_]*)(%d*)") do
				if text ~= "" then table_insert(segments, text) end
				if number ~= "" then table_insert(segments, tonumber(number)) end
			end
			return segments
		end

		local aParts = split(a.Name)
		local bParts = split(b.Name)

		for i = 1, math_max(#aParts, #bParts) do
			local aVal = aParts[i]
			local bVal = bParts[i]

			if aVal == nil then return true end
			if bVal == nil then return false end

			local typeNameA = type(aVal)
			local typeNameB = type(bVal)
			if typeNameA == "string" and typeNameB == "string" then
				if aVal ~= bVal then
					return aVal < bVal
				end
			elseif typeNameA == "number" and typeNameB == "number" then
				if aVal ~= bVal then
					return aVal < bVal
				end
			elseif typeNameA ~= type(bVal) then
				return typeNameA == "string"
			end
		end

		return false
	end)
	
	return partList
end

function Util:CreateSortComparers(comparers)
	return function(a, b)
		for index = 1, #comparers do
			local comparer = comparers[index]
			local val_a = comparer(a)
			local val_b = comparer(b)
			if val_a < val_b then
				return true   -- a 排在 b 前面
			elseif val_a > val_b then
				return false  -- b 排在 a 前面
			end
			-- 当前条件比较结果相等，继续下一个条件
		end
		return false -- 所有条件均相等，默认保留原有顺序
	end
end

function Util:ListFind(array, condition)
	if not array then return nil end
	if not condition then return nil end
	for index = 1, #array do
		local item = array[index]
		if condition(item) then
			return item
		end
	end
	return nil
end

function Util:ListFindAll(array, condition)
	local result = {}
	if not array then return result end
	if not condition then return result end
	for index = 1, #array do
		local item = array[index]
		if condition(item) then
			table_insert(result, item)
		end
	end
	return result
end

function Util:ListFindMany(array, count, condition)
	local result = {}
	if not array then return result end
	for index = 1, #array do
		local item = array[index]
		if condition and condition(item) then
			table_insert(result, item)
		else
			table_insert(result, item)
		end
		
		if #result >= count then
			break
		end
	end
	return result
end

function Util:ListSelect(array, selector)
	local result = {}
	if not array then return result end
	for index = 1, #array do
		local item = array[index]
		local selectItem = selector(item)
		table_insert(result, selectItem)
	end
	return result
end

function Util:ListMax(array, selector)
  	local max = -999999999999999
	local findItem = nil
	for index = 1, #array do
		local item = array[index]
		local selectItem = selector(item)
		if selectItem > max then
			max = selectItem
			findItem = item
		end
	end
	
	return findItem
end

function Util:ListMin(array, selector)
	local min = 999999999999999
	local findItem = nil
	for index = 1, #array do
		local item = array[index]
		local selectItem = selector(item)
		if selectItem < min then
			min = selectItem
			findItem = item
		end
	end

	return findItem
end

function Util:ListSelectStart(array, count)
	local result = {}
	local counter = 0
	for index = 1, #array do
		local item = array[index]
		if counter < count then
			result[index] = item
			counter = counter + 1
		else
			break
		end
	end
	return result
end

function Util:ListIndexOf(array, value)
	for index = 1, #array do
		local item = array[index]
		if item == value then
			return index
		end
	end
	
	return -1
end

------------------------------------------------------------------------------------
-- Rand
-- Item = { Weight = xxx }

function Util:ListRandomWeight(weightList, count)
	count = count or 1
	if not weightList or #weightList == 0 then return nil end

	local prefix = {}
	local total = 0

	for index = 1, #weightList do
		local item = weightList[index]
		total += item.Weight
		prefix[index] = total
	end

	local function pickOne()
		local r = math_random() * total
		for index = 1, #prefix do
			local value = prefix[index]
			if r <= value then
				return weightList[index]
			end
		end
	end

	if count == 1 then
		return pickOne()
	end

	local result = {}
	for i = 1, count do
		result[i] = pickOne()
	end

	return result
end

------------------------------------------------------------------------------------
-- Table

function Util:TableCount(array, condition)
	if not array then return 0 end
	local count = 0
	for _, item in pairs(array) do
		if condition and condition(item) then
			count = count + 1
		else
			count = count + 1
		end
	end
	return count
end

function Util:TableContains(array, value)
	if not array then return false end
	for _, item in pairs(array) do
		if item == value then
			return true
		end
	end
	return false
end

function Util:TableSum(array, valueGetter)
	if not array then return 0 end
	local count = 0
	for _, item in pairs(array) do
		count = count + valueGetter(item)
	end
	return count
end

function Util:TableFind(luaTable, condition)
	if not luaTable then return nil end
	for _, item in pairs(luaTable) do
		if condition then
			if condition(item) then
				return item
			end
		end
	end
	return nil
end

function Util:TableFindAll(luaTable, condition)
	local result = {}
	if not luaTable then return result end
	for _, item in pairs(luaTable) do
		if condition then
			if condition(item) then
				table_insert(result, item)
			end
		else
			table_insert(result, item)
		end
	end
	return result
end

function Util:TableFindMany(luaTable, count, condition)
	local result = {}
	if not luaTable then return result end
	for _, item in pairs(luaTable) do
		if condition then
			if condition(item) then
				table_insert(result, item)
			end
		else
			table_insert(result, item)
		end
		if #result >= count then
			break
		end
	end
	return result
end

function Util:TableSelect(luaTable, selector)
	local result = {}
	if not luaTable then return result end
	for _, item in pairs(luaTable) do
		local selectItem = selector(item)
		table_insert(result, selectItem)
	end
	return result
end

function Util:TableMax(luaTable, selector)
	local max = -999999999999999
	local findItem = nil
	for _, item in pairs(luaTable) do
		local selectItem = selector(item)
		if selectItem > max then
			max = selectItem
			findItem = item
		end
	end

	return findItem
end

function Util:TableMin(luaTable, selector)
	local min = 999999999999999
	local findItem = nil
	for _, item in pairs(luaTable) do
		local selectItem = selector(item)
		if selectItem < min then
			min = selectItem
			findItem = item
		end
	end

	return findItem
end

function Util:TableCopy(orig)
	local copy = {}
	for key, value in pairs(orig) do
		if type(value) == "table" then
			copy[key] = Util:TableCopy(value)
		else
			copy[key] = value
		end
	end
	return copy
end

function Util:TableCopyRequieKey(luaTable, result)
	if not luaTable then return end
	for key, value in pairs(luaTable) do
		if result[key] ~= nil then
			result[key] = value
		end
	end
end

function Util:TableMerge(table1, table2)
	for k, v in pairs(table2) do
		if table1[k] == nil then
			table1[k] = v
		end
	end
	return table1
end

function Util:TableRandom(luaTable)
	if not luaTable then return nil end
	local keys = {}
	for k in pairs(luaTable) do
		table_insert(keys, k)
	end
	if #keys == 0 then return nil end
	local randomKey = keys[math_random(#keys)]
	return luaTable[randomKey], randomKey
end

------------------------------------------------------------------------------------
-- Guid

function Util:NewGuid()
	return HttpService:GenerateGUID(false)
end

------------------------------------------------------------------------------------
-- Color

function Util:ColorToHtml(color)
	-- RGB
	local r = math_floor(color.R * 255 + 0.5)
	local g = math_floor(color.G * 255 + 0.5)
	local b = math_floor(color.B * 255 + 0.5)

	-- #RRGGBB
	return string_format("#%02X%02X%02X", r, g, b)
end

function Util:ToColorText(str, color)
	local colorTag = Util:ColorToHtml(color)
	local result = "<font color=\""..colorTag.."\">"..str.."</font>"
	return result
end

------------------------------------------------------------------------------------
-- Object - Position

function Util:SetPosition(object, position)
	if object:IsA("Model") then
		local pivot = object:GetPivot()
		local newCFrame = CFrame_new(position) * CFrame.Angles(pivot:ToEulerAnglesXYZ())
		object:PivotTo(newCFrame)
	else
		object.Position = position
	end
end

function Util:GetPosition(object, position)
	if object:IsA("Model") then
		return object:GetPivot().Position
	else
		return object.Position
	end
end

function Util:SetScaleValue(object, scaleValue)
	Util:SetScale(object, Vector3_new(scaleValue, scaleValue, scaleValue))
end

function Util:GetScaleValue(object, scaleValue)
	local scale = Util:GetScale(object)
	local scaleValue = (scale.x + scale.y + scale.z) / 3
	return scaleValue
end

function Util:SetScale(object, scale)
	if object:IsA("Model") then
		local modelUtil = require(game.ReplicatedStorage.ScriptAlias.ModelUtil)
		modelUtil:SetScale(object, scale)
	else
		object.Size = scale
	end
end

function Util:GetScale(object, scaleValue)
	if object:IsA("Model") then
		return object:GetScale()
	else
		return object.Size
	end
end

function Util:SetRotation(object, rotation)
	if object:IsA("Model") then
		local pivot = object:GetPivot()
		local newCFrame = CFrame_new(pivot.Position) * CFrame.Angles(
			math_rad(rotation.X),
			math_rad(rotation.Y),
			math_rad(rotation.Z)
		)
		object:PivotTo(newCFrame)
	else
		object.Orientation = Vector3_new(rotation.X, rotation.Y, rotation.Z)
	end
end

function Util:GetRotation(object)
	if object:IsA("Model") then
		local rx, ry, rz = object:GetPivot():ToOrientation()
		return Vector3_new(math_deg(rx), math_deg(ry), math_deg(rz))
	else
		return object.Orientation
	end
end


function Util:SetForward(object, forward)
	if object:IsA("Model") then
		local modelUtil = require(game.ReplicatedStorage.ScriptAlias.ModelUtil)
		modelUtil:SetForward(object, forward)
	else
		object.CFrame = CFrame.fromMatrix(object.Position, forward, Vector3.yAxis)
	end
end

------------------------------------------------------------------------------------
-- CFrame

function Util:CFrameFromAngles360(rotation)
	return CFrame.fromEulerAnglesXYZ(math_rad(rotation.x), math_rad(rotation.y), math_rad(rotation.z))
end

------------------------------------------------------------------------------------
-- Folder

function Util:GetReplicatedFolder(folderName)
	local folder = game.ReplicatedStorage:FindFirstChild(folderName)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = folderName
		folder.Parent = game.ReplicatedStorage
	end
	return folder
end

function Util:GetWorkspaceFolder(folderName)
	local folder = game.Workspace:FindFirstChild(folderName)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = folderName
		folder.Parent = game.Workspace
	end
	return folder
end

------------------------------------------------------------------------------------
-- Active DeActive (Show / Hide) - Move to replicatedStoreage

local DeActiveCache = {}
local DeActiveFolder = Util:GetReplicatedFolder("RuntimeOnly_DeActive")

function Util:ActiveObject(object)
	if not object or not object:IsA("Instance") then return end
	
	local info = DeActiveCache[object]
	if not info or not info.Parent or not info.Parent:IsA("Instance") then return end
	
	object.Parent = info.Parent
	DeActiveCache[object] = nil
end

function Util:DeActiveObject(object)
	if not object or not object:IsA("Instance") then return end
	if DeActiveCache[object] then return end
	
	DeActiveCache[object] = { Parent = object.Parent }
	object.Parent = DeActiveFolder
end

------------------------------------------------------------------------------------
-- Fx

function Util:SpawnFx(fxPrefab, pos, destroyTime)
	local fx = fxPrefab:Clone()
	fx.Position = pos
	local sceneMnaager = require(game.ReplicatedStorage.ScriptAlias.SceneManager)
	fx.Parent = sceneMnaager.LevelRoot.Game.Fx
	if not destroyTime then
		destroyTime = 1
	end
	
	task.delay(destroyTime, function()
		fx:Destroy()
	end)	
end

function Util:SpawnFxEmit(fxPrefab, pos, rate, destroyTime)
	local fx = fxPrefab:Clone()
	fx.Position = pos
	local sceneMnaager = require(game.ReplicatedStorage.ScriptAlias.SceneManager)
	fx.Parent = sceneMnaager.LevelRoot.Game.Fx
	local particleEmitters = Util:GetAllChildByType(fx, "ParticleEmitter")
	for _, particleEmitter in ipairs(particleEmitters) do
		particleEmitter:Emit(rate)
	end
	
	if not destroyTime then
		destroyTime = 1
	end
	
	task.delay(destroyTime, function()
		fx:Destroy()
	end)
	
	return fx
end

function Util:SpawnScreenFx(fxPrefab, destroyTime)
	local fx = fxPrefab:Clone()
	
	fx.Parent = game.Players.LocalPlayer.PlayerGui
	fx.Enabled = false
	task.wait()
	fx.Enabled = true
	if destroyTime == nil then
		destroyTime = 1
	end
	
	if destroyTime > 0 then
		task.delay(destroyTime, function()
			fx:Destroy()
		end)	
	end	
	
	return fx
end

return Util