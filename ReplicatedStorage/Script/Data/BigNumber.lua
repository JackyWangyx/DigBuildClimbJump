BigNumber = {}

-- 定义单位（从 K 到 F）
--BigNumber.Unit = { "K", "M", "B", "T", "P", "E", "Z", "Y", "A", "D", "F" }
BigNumber.Unit = { "K", "M", "B", "T", "Qa" }

-- 格式化大数
function BigNumber:Format(number)
	-- 转换为字符串，确保可以获取长度
	local numStr = tostring(number)

	-- 如果长度小于等于 3，则直接返回
	if #numStr <= 3 then
		return numStr
	end

	-- 确保是数值类型
	local value = tonumber(number)

	-- 四舍五入
	value = math.floor(value + 0.5)

	-- 如果小于 1000，直接返回
	if value < 1000 then
		return tostring(value)
	end

	local unitIndex = 1
	local current = 1

	-- 计算应该使用的单位
	while unitIndex <= #BigNumber.Unit do
		current = current * 1000
		local nextValue = current * 1000
		if value >= current and value < nextValue then
			value = value / current
			break
		end
		unitIndex = unitIndex + 1
	end

	-- 获取对应的单位
	local unit = BigNumber.Unit[unitIndex] or ""

	-- 格式化数值，最多保留 3 位有效字符
	local str = string.format("%.2f", value)

	-- 移除末尾无意义的 0
	str = str:gsub("(%.%d-)0+$", "%1")
	str = str:gsub("%.$", "")

	return str .. unit
end

return BigNumber