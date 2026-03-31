local HttpService = game:GetService("HttpService")

local SignatureUtil = {}

function SignatureUtil:Init()
	
end

local bit = bit32

function SignatureUtil:Hash(str, length)
	length = length or 8
	local hash = 2166136261

	for i = 1, #str do
		hash = bit.bxor(hash, string.byte(str, i))
		hash = (hash * 16777619) % 2^32
	end
	local hex = string.format("%08x", hash)
	return string.sub(hex, 1, length)
end

function SignatureUtil:GenerateKey()
	return HttpService:GenerateGUID(false)
end

local function IsArray(tbl)
	for k, _ in pairs(tbl) do
		if typeof(k) ~= "number" then
			return false
		end
	end
	-- 检查是否连续
	local count = #tbl
	for i = 1, count do
		if tbl[i] == nil then
			return false
		end
	end
	return true
end

-- 稳定排序 JSON 编码
local function Encode(tbl)
	if typeof(tbl) ~= "table" then
		-- 基础类型直接转 JSON
		return HttpService:JSONEncode(tbl)
	end

	if IsArray(tbl) then
		-- 数组：保持顺序
		local arr = {}
		for i = 1, #tbl do
			arr[i] = Encode(tbl[i])
		end
		return "[" .. table.concat(arr, ",") .. "]"
	else
		-- 字典：按 key 排序
		local keys = {}
		for k in pairs(tbl) do
			table.insert(keys, k)
		end
		table.sort(keys, function(a, b)
			return tostring(a) < tostring(b)
		end)

		local parts = {}
		for _, k in ipairs(keys) do
			local keyStr = HttpService:JSONEncode(k)
			local valStr = Encode(tbl[k])
			table.insert(parts, keyStr .. ":" .. valStr)
		end
		return "{" .. table.concat(parts, ",") .. "}"
	end
end

function SignatureUtil:Sign(data, key)
	if not key then
		return "9512"
	end
	local serializedData = Encode(data)
	local hash = SignatureUtil:Hash(serializedData .. key)
	return hash
end

return SignatureUtil
