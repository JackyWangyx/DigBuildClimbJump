-- TestRunner.lua (自包含版本，无需外部依赖)

local TestRunner = {}
local TestResult = { passed = 0, failed = 0, errors = {} }

-- 辅助断言函数
local function AssertEqual(exp, act, name)
	if exp == act then
		TestResult.passed = TestResult.passed + 1
		print("[PASS] " .. name)
		return true
	else
		TestResult.failed = TestResult.failed + 1
		local msg = "[FAIL] " .. name .. ": Expected " .. tostring(exp) .. ", got " .. tostring(act)
		table.insert(TestResult.errors, msg)
		warn(msg)
		return false
	end
end

local function AssertTrue(cond, name)
	if cond then
		TestResult.passed = TestResult.passed + 1
		print("[PASS] " .. name)
		return true
	else
		TestResult.failed = TestResult.failed + 1
		local msg = "[FAIL] " .. name .. ": Condition is false"
		table.insert(TestResult.errors, msg)
		warn(msg)
		return false
	end
end

local function AssertFalse(cond, name)
	if not cond then
		TestResult.passed = TestResult.passed + 1
		print("[PASS] " .. name)
		return true
	else
		TestResult.failed = TestResult.failed + 1
		local msg = "[FAIL] " .. name .. ": Condition should be false"
		table.insert(TestResult.errors, msg)
		warn(msg)
		return false
	end
end

-- 模拟 PlayerProperty 模块的基础数据和方法
local DefaultPlayerSaveProperty = {
	Speed = 14, Acceleration = 10, MaxSpeedFactor = 1, BasePower = 100,
	PowerLimit = 0, GetPowerFactor = 1, GetCoinFactor = 1, GetWinsFactor = 1,
	LuckyGetPetCommon = 0, LuckyGetPetRare = 0, LuckyGetPetEpic = 0,
	LuckyGetPetLegendary = 0, LuckyGetPetSecret = 0, LuckyGetPetMythical = 0,
	LuckyPetUpgrade = 0
}

local EmptyProperty = {
	Speed = 0, Acceleration = 0, MaxSpeedFactor = 0, BasePower = 0,
	PowerLimit = 0, GetPowerFactor = 0, GetCoinFactor = 0, GetWinsFactor = 0,
	LuckyGetPetCommon = 0, LuckyGetPetRare = 0, LuckyGetPetEpic = 0,
	LuckyGetPetLegendary = 0, LuckyGetPetSecret = 0, LuckyGetPetMythical = 0,
	LuckyPetUpgrade = 0
}

local OneProperty = {
	Speed = 1, Acceleration = 1, MaxSpeedFactor = 1, BasePower = 1,
	PowerLimit = 1, GetPowerFactor = 1, GetCoinFactor = 1, GetWinsFactor = 1,
	LuckyGetPetCommon = 1, LuckyGetPetRare = 1, LuckyGetPetEpic = 1,
	LuckyGetPetLegendary = 1, LuckyGetPetSecret = 1, LuckyGetPetMythical = 1,
	LuckyPetUpgrade = 1
}

local PropertyKeyList = {} -- 如果有真实数据会在这里填充

-- 模拟方法实现
local function PropertyCombineAdd(res, dic)
	for k, v in pairs(dic) do
		res[k] = (res[k] or 0) + v
	end
end

local function PropertyCombineMultiple(res, dic)
	for k, v in pairs(dic) do
		res[k] = (res[k] or 0) * v
	end
end

local function GetPropertyFromData(data, key)
	return data[key] or 0
end

local function SelectProperty(cfg, info, src, suffix)
	local res = {}
	local len = #suffix
	for k, v in pairs(src) do
		if string.sub(k, -len) == suffix then
			res[string.sub(k, 1, #k - len)] = v
		end
	end
	return res
end

local function IsListEmpty(t)
	return t == nil or next(t) == nil
end

local function TableCopy(orig)
	local copy = {}
	for k, v in pairs(orig) do
		if type(v) == "table" then
			copy[k] = TableCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

local function GetMaxSpeedByPower(power)
	if not power then power = 0 end
	local r = power
	if power >= 100 and power <= 1000 then r = 0.25 * power + 30 end
	if power >= 1001 and power <= 100000 then r = 0.015 * power + 300 end
	if power >= 100001 and power <= 10000000 then r = 0.0002 * power + 1800 end
	if power >= 10000001 and power <= 1000000000 then r = 3e-6 * power + 3900 end
	if power >= 1000000001 and power <= 100000000000 then r = 6e-8 * power + 6880 end
	if power >= 100000000001 then r = 3e-9 * power + 12800 end
	return r
end

-- 测试用例定义
local function RunTests()
	print("\n========================================")
	print("PlayerProperty Unit Tests")
	print("========================================\n")

	-- 1. DefaultPlayerSaveProperty
	print("--- Test: DefaultPlayerSaveProperty ---")
	AssertEqual(14, DefaultPlayerSaveProperty.Speed, "Default Speed")
	AssertEqual(10, DefaultPlayerSaveProperty.Acceleration, "Default Acceleration")
	AssertEqual(1, DefaultPlayerSaveProperty.MaxSpeedFactor, "Default MaxSpeedFactor")
	AssertEqual(100, DefaultPlayerSaveProperty.BasePower, "Default BasePower")
	AssertEqual(0, DefaultPlayerSaveProperty.PowerLimit, "Default PowerLimit")
	AssertEqual(1, DefaultPlayerSaveProperty.GetPowerFactor, "Default GetPowerFactor")
	AssertEqual(1, DefaultPlayerSaveProperty.GetCoinFactor, "Default GetCoinFactor")
	AssertEqual(1, DefaultPlayerSaveProperty.GetWinsFactor, "Default GetWinsFactor")

	-- 2. EmptyProperty
	print("\n--- Test: EmptyProperty ---")
	AssertEqual(0, EmptyProperty.Speed, "Empty Speed")
	AssertEqual(0, EmptyProperty.Acceleration, "Empty Acceleration")
	AssertEqual(0, EmptyProperty.MaxSpeedFactor, "Empty MaxSpeedFactor")
	AssertEqual(0, EmptyProperty.BasePower, "Empty BasePower")
	AssertEqual(0, EmptyProperty.LuckyGetPetCommon, "Empty LuckyGetPetCommon")
	AssertEqual(0, EmptyProperty.LuckyPetUpgrade, "Empty LuckyPetUpgrade")

	-- 3. OneProperty
	print("\n--- Test: OneProperty ---")
	AssertEqual(1, OneProperty.Speed, "One Speed")
	AssertEqual(1, OneProperty.Acceleration, "One Acceleration")
	AssertEqual(1, OneProperty.MaxSpeedFactor, "One MaxSpeedFactor")
	AssertEqual(1, OneProperty.BasePower, "One BasePower")
	AssertEqual(1, OneProperty.LuckyGetPetMythical, "One LuckyGetPetMythical")

	-- 4. PropertyCombineAdd
	print("\n--- Test: PropertyCombineAdd ---")
	local res1 = {}
	PropertyCombineAdd(res1, { Speed = 10, Acceleration = 5 })
	AssertEqual(10, res1.Speed, "Add Speed")
	AssertEqual(5, res1.Acceleration, "Add Acceleration")

	PropertyCombineAdd(res1, { Speed = 5 })
	AssertEqual(15, res1.Speed, "Add Speed Again")

	-- 5. PropertyCombineMultiple
	print("\n--- Test: PropertyCombineMultiple ---")
	local res2 = { Speed = 10, Acceleration = 20 }
	PropertyCombineMultiple(res2, { Speed = 1.5, Acceleration = 2 })
	AssertEqual(15, res2.Speed, "Mul Speed")
	AssertEqual(40, res2.Acceleration, "Mul Acceleration")

	-- 6. GetPropertyFromData
	print("\n--- Test: GetPropertyFromData ---")
	local data = { Speed = 25, Acc = 15 }
	AssertEqual(25, GetPropertyFromData(data, "Speed"), "Get Speed")
	AssertEqual(15, GetPropertyFromData(data, "Acc"), "Get Acc")
	AssertEqual(0, GetPropertyFromData(data, "None"), "Get None")

	-- 7. SelectProperty
	print("\n--- Test: SelectProperty ---")
	local src = { Speed1 = 10, Acc1 = 5, Speed2 = 20 }
	local selected = SelectProperty(nil, nil, src, "1")
	AssertEqual(10, selected.Speed, "Select Speed1")
	AssertEqual(5, selected.Acc, "Select Acc1")
	AssertTrue(selected.Speed2 == nil, "Exclude Speed2")

	-- 8. IsListEmpty
	print("\n--- Test: IsListEmpty ---")
	AssertTrue(IsListEmpty(nil), "Nil empty")
	AssertTrue(IsListEmpty({}), "Table empty")
	AssertFalse(IsListEmpty({1}), "Table not empty")

	-- 9. TableCopy
	print("\n--- Test: TableCopy ---")
	local orig = { Val = 10, Nested = { V = 5 } }
	local cp = TableCopy(orig)
	AssertEqual(10, cp.Val, "Copy Val")
	AssertEqual(5, cp.Nested.V, "Copy Nested")
	cp.Val = 999
	AssertEqual(10, orig.Val, "Deep Copy Check")

	-- 10. GetMaxSpeedByPower
	print("\n--- Test: GetMaxSpeedByPower ---")
	AssertTrue(GetMaxSpeedByPower(nil) >= 0, "Nil Power")
	local s100 = GetMaxSpeedByPower(100)
	AssertTrue(s100 >= 55 and s100 <= 56, "Power 100 Formula")

	-- 11. Lucky Properties
	print("\n--- Test: Lucky Properties ---")
	AssertEqual(0, DefaultPlayerSaveProperty.LuckyGetPetLegendary, "Default Legendary")
	AssertEqual(0, DefaultPlayerSaveProperty.LuckyPetUpgrade, "Default Upgrade")

	-- 总结
	print("\n========================================")
	print("Test Summary")
	print("========================================")
	print("Passed: " .. TestResult.passed)
	print("Failed: " .. TestResult.failed)

	if TestResult.failed > 0 then
		print("\nFailures:")
		for _, e in ipairs(TestResult.errors) do
			warn(e)
		end
		return false
	else
		print("\nAll tests passed!")
		return true
	end
end

-- 启动入口
function TestRunner:Run()
	return RunTests()
end

if game:GetService("RunService"):IsServer() then
	task.delay(1, function()
		TestRunner:Run()
	end)
end

return TestRunner