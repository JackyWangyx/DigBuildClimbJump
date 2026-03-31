local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local AttributeUtil = {}

local PREFIX = {
	Data = "Data_",
	Info = "Info_",
}

-- 内部：生成完整 Key
local function getKey(prefix, key)
	if not Util:IsStrStartWith(key, prefix) then
		return prefix .. key
	end
	return key
end

-- 内部：获取/设置单值
local function getValue(part, prefix, key)
	if not part then return nil end
	return part:GetAttribute(getKey(prefix, key))
end

local function setValue(part, prefix, key, value)
	if not part then return end
	part:SetAttribute(getKey(prefix, key), value)
end

-- 内部：批量获取/设置
local function getAll(part, prefix)
	if not part then return nil end
	local result = {}
	for name, val in pairs(part:GetAttributes()) do
		if Util:IsStrStartWith(name, prefix) then
			local shortKey = string.gsub(name, "^" .. prefix, "")
			result[shortKey] = val
		end
	end
	return result
end

local function setAll(part, prefix, data)
	if not part or not data then return end
	for key, val in pairs(data) do
		setValue(part, prefix, key, val)
	end
end

-- Data API
function AttributeUtil:GetDataKey(key) return getKey(PREFIX.Data, key) end
function AttributeUtil:GetDataValue(part, key) return getValue(part, PREFIX.Data, key) end
function AttributeUtil:SetDataValue(part, key, value) return setValue(part, PREFIX.Data, key, value) end
function AttributeUtil:GetData(part) return getAll(part, PREFIX.Data) end
function AttributeUtil:SetData(part, data) return setAll(part, PREFIX.Data, data) end

-- Info API
function AttributeUtil:GetInfoKey(key) return getKey(PREFIX.Info, key) end
function AttributeUtil:GetInfoValue(part, key) return getValue(part, PREFIX.Info, key) end
function AttributeUtil:SetInfoValue(part, key, value) return setValue(part, PREFIX.Info, key, value) end
function AttributeUtil:GetInfo(part) return getAll(part, PREFIX.Info) end
function AttributeUtil:SetInfo(part, info) return setAll(part, PREFIX.Info, info) end

-- 清理所有属性
function AttributeUtil:Clear(part)
	if not part then return end
	for name in pairs(part:GetAttributes()) do
		part:SetAttribute(name, nil)
	end
end

return AttributeUtil
