StackList = {}
StackList.__index = StackList

-- 创建堆栈
function StackList.new()
	local self = setmetatable({}, StackList)
	self.ItemList = {}  -- 用一个表来存储堆栈中的元素
	return self
end

-- 压入一个元素（键值对）
function StackList:Push(key, value)
	table.insert(self.ItemList, {Key = key, Value = value})
end

-- 弹出一个元素
function StackList:Pop()
	return table.remove(self.ItemList)
end

-- 获取堆栈顶部元素（不弹出）
function StackList:Top()
	return self.ItemList[#self.ItemList]
end

-- 获取堆栈底部元素（不弹出）
function StackList:Bottom()
	return self.ItemList[1]
end

-- 获取堆栈的大小
function StackList:Count()
	return #self.ItemList
end

function StackList:Clear()
	self.ItemList = {}
end

-- 检查堆栈中是否存在指定的键或值
function StackList:Exist(key_or_value)
	for _, item in ipairs(self.ItemList) do
		if item.Key == key_or_value or item.Value == key_or_value then
			return true
		end
	end
	return false
end

-- 获取指定键对应的值（如果存在）
function StackList:Get(key)
	for _, item in ipairs(self.ItemList) do
		if item.Key == key then
			return item.Value
		end
	end
	return nil  -- 如果没有找到指定的键，返回 nil
end

function StackList:Log()
	print(self.ItemList)
end

return StackList