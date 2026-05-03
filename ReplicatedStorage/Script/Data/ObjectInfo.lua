----------------------------------------------------------
-- 用于在任意对象上存储和获取信息，替代有性能问题的 AttributeUtil 

local ObjectInfo = {}

local table_clone = table.clone
local table_clear = table.clear

local Cache = setmetatable({}, { __mode = "k" })

function ObjectInfo:GetCache(object)
	local cache = Cache[object]
	if not cache then
		cache = {
			Info = {},
			Data = {},
		}
		
		Cache[object] = cache
	end
	
	return cache
end

----------------------------------------------------------
-- Info

function ObjectInfo:GetInfo(object)
	local cache = ObjectInfo:GetCache(object)
	local info = cache.Info
	return info
end

function ObjectInfo:SetInfo(object, info)
	local cache = ObjectInfo:GetCache(object)
	cache.Info = table.clone(info)
end

function ObjectInfo:GetInfoValue(object, key)
	local cache = ObjectInfo:GetCache(object)
	local value = cache.Info[key]
	return value
end

function ObjectInfo:SetInfoValue(object, key, value)
	local cache = ObjectInfo:GetCache(object)
	cache.Info[key] = value
end

----------------------------------------------------------
-- Data

function ObjectInfo:GetData(object)
	local cache = ObjectInfo:GetCache(object)
	local data = cache.Data
	return data
end

function ObjectInfo:SetData(object, data)
	local cache = ObjectInfo:GetCache(object)
	cache.Data = table_clone(data)
end

function ObjectInfo:GetDataValue(object, key)
	local cache = ObjectInfo:GetCache(object)
	local value = cache.Data[key]
	return value
end

function ObjectInfo:SetDataValue(object, key, value)
	local cache = ObjectInfo:GetCache(object)
	cache.Data[key] = value
end

----------------------------------------------------------
-- Clear

function ObjectInfo:Clear(object)
	local cache = ObjectInfo:GetCache(object)
	table_clear(cache.Info)
	table_clear(cache.Data)
end

return ObjectInfo