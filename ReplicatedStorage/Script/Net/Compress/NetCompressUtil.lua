local NetDefine = require(script.Parent.Parent.NetDefine)
local NetKeyMap = require(script.Parent.NetKeyMap)

local NetCompressUtil = {}

function NetCompressUtil:Init()
	NetKeyMap:Init()
end

-- 判断是否为数组（顺序数组，不包含字符串键）
local function isArray(data)
	local count = 0
	for key, _ in pairs(data) do
		if type(key) ~= "number" then return false end
		count += 1
	end
	return #data == count
end

function NetCompressUtil:Compress(data)
	if type(data) ~= "table" then
		return data
	end

	local compressed = {}
	local keyMap = NetKeyMap.KeyMap

	if isArray(data) then
		for index, value in ipairs(data) do
			compressed[index] = NetCompressUtil:Compress(value)
		end
	else
		for key, value in pairs(data) do
			local shortKey
			if type(key) ~= "number" then
				shortKey = keyMap[key]
				if not shortKey then
					if NetDefine.UpdateNetKeyMap then
						-- Update Key Map
						if not NetKeyMap.KeyMapTemp[key] then
							local count = NetKeyMap:GetTempCount() + 1
							local newShortKey = tostring(count)
							NetKeyMap.KeyMapTemp[key] = newShortKey
							print("✅ Update Net Key Map : ", count, NetKeyMap.KeyMapTemp)
						end
					end
					
					shortKey = key
				end
			else
				shortKey = key
			end
			
			if type(value) == "table" then
				compressed[shortKey] = NetCompressUtil:Compress(value)
			else
				compressed[shortKey] = value
			end
		end
	end

	return compressed
end

function NetCompressUtil:Decompress(data)
	if type(data) ~= "table" then
		return data
	end

	local decompressed = {}
	local reverseMap = NetKeyMap.ReserveKeyMap

	if isArray(data) then
		for index, value in ipairs(data) do
			decompressed[index] = NetCompressUtil:Decompress(value)
		end
	else
		for key, value in pairs(data) do
			local longKey = reverseMap[key] or key
			if type(value) == "table" then
				decompressed[longKey] = NetCompressUtil:Decompress(value)
			else
				decompressed[longKey] = value
			end
		end
	end

	return decompressed
end

return NetCompressUtil
