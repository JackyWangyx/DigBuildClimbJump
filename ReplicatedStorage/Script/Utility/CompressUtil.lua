local HttpService = game:GetService("HttpService")

local CompressUtil = {}

-- Json
function CompressUtil:ToJson(obj)
	local json = HttpService:JSONEncode(obj)
	return json
end

function CompressUtil:ToObj(json)
	local obj = HttpService:JSONDecode(json)
	return obj
end

-- Obj 根据 KeyMap 替换短 Key 以压缩数据
function CompressUtil:CompressObj(data, keyMap)
	local compressed = {}
	for key, value in pairs(data) do
		local shortKey = keyMap[key] or key  -- 保留未匹配Key
		if type(value) == "table" then
			compressed[shortKey] = CompressUtil:CompressObj(value, keyMap)
		else
			compressed[shortKey] = value
		end
	end

	return compressed
end

function CompressUtil:DecompressObj(data, keyMap)
	local decompressed = {}
	local reverseMap = {}

	-- 反向字典：数字 → 字符串Key
	for origKey, shortKey in pairs(keyMap) do
		reverseMap[shortKey] = origKey
	end

	for key, value in pairs(data) do
		local longKey = reverseMap[key] or key  -- 保留未匹配Key
		if type(value) == "table" then
			decompressed[longKey] = CompressUtil:DecompressObj(value, keyMap)
		else
			decompressed[longKey] = value
		end
	end

	return decompressed
end

-- Str LZW7 适合短字符串 500B - 5KB
function CompressUtil:CompressStrMin(input, windowSize)
	windowSize = windowSize or 64
	local i = 1
	local output = {}

	while i <= #input do
		local maxLen, bestOffset = 0, 0
		local windowStart = math.max(1, i - windowSize)

		for j = windowStart, i - 1 do
			local len = 0
			while input:sub(j + len, j + len) == input:sub(i + len, i + len)
				and (j + len) < i and (i + len) <= #input do
				len = len + 1
			end
			if len > maxLen then
				maxLen = len
				bestOffset = i - j
			end
		end

		if maxLen >= 3 then
			table.insert(output, string.format("<%d,%d>", bestOffset, maxLen))
			i = i + maxLen
		else
			table.insert(output, input:sub(i, i))
			i = i + 1
		end
	end

	return table.concat(output)
end

function CompressUtil:DecompressStrMin(input)
	local output = {}
	local i = 1

	while i <= #input do
		if input:sub(i, i) == "<" then
			local close = input:find(">", i)
			local token = input:sub(i + 1, close - 1)
			local offset, length = token:match("(%d+),(%d+)")
			offset, length = tonumber(offset), tonumber(length)

			local pos = #output - offset + 1
			for j = 1, length do
				table.insert(output, output[pos])
				pos = pos + 1
			end

			i = close + 1
		else
			table.insert(output, input:sub(i, i))
			i = i + 1
		end
	end

	return table.concat(output)
end

-- Str LZW 适合长字符串
function CompressUtil:CompressStrMax(input)
	local dict = {}
	for i = 0, 255 do
		dict[string.char(i)] = i
	end

	local currStr = ""
	local result = {}
	local dictSize = 256

	for i = 1, #input do
		local c = input:sub(i, i)
		local combined = currStr .. c
		if dict[combined] then
			currStr = combined
		else
			table.insert(result, dict[currStr])
			dict[combined] = dictSize
			dictSize = dictSize + 1
			currStr = c
		end
	end

	if currStr ~= "" then
		table.insert(result, dict[currStr])
	end

	-- 把数字压缩成字符存储（将数字用char打包）
	local output = {}
	for _, code in ipairs(result) do
		table.insert(output, string.char(math.floor(code / 256), code % 256))
	end

	return table.concat(output)
end

function CompressUtil:DecompressStrMax(input)
	local dict = {}
	for i = 0, 255 do
		dict[i] = string.char(i)
	end

	local data = {}
	for i = 1, #input, 2 do
		local hi = input:byte(i)
		local lo = input:byte(i + 1)
		table.insert(data, hi * 256 + lo)
	end

	local prevCode = data[1]
	local prevStr = dict[prevCode]
	local result = { prevStr }
	local dictSize = 256

	for i = 2, #data do
		local code = data[i]
		local entry = dict[code]

		if not entry then
			entry = prevStr .. prevStr:sub(1, 1)
		end

		table.insert(result, entry)
		dict[dictSize] = prevStr .. entry:sub(1, 1)
		dictSize = dictSize + 1
		prevStr = entry
	end

	return table.concat(result)
end


return CompressUtil
