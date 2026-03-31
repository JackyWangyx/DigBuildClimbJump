-- [👨 玩家属性]

-- 数值
-- BasePower = 10,			-- 初始 Power
-- TrainingPower = 0,		-- 训练获得的 Power
-- Acceleration = 10,		-- 加速度
-- MaxSpeedFactor = 1，		-- 最大速度加成百分比

-- 百分比

-- [📁 玩家属性]

-- GetPowerFactor = 1,		-- 获取速度倍率系数 1 = 100% 1 倍
-- GetCoinFactor = 1,		-- 获取金币倍率系数
-- GetWinsFactor = 1,		-- 获取奖杯倍率系数

-- 百分比
-- LuckyGetPetCommon = 0,		-- 抽奖1稀有度 加成概率
-- LuckyGetPetRare = 0,			-- 抽奖2稀有度 加成概率				
-- LuckyGetPetEpic = 0,			-- 抽奖3稀有度 加成概率
-- LuckyGetPetLegendary = 0,	-- 抽奖4稀有度 加成概率
-- LuckyGetPetSecret = 0,		-- 抽奖5稀有度 加成概率
-- LuckyGetPetMythical = 0,		-- 抽奖6稀有度 加成概率

-- 百分比
-- LuckyPetUpgrade = 0,		-- 抽奖直接突破 加成概率

-- 生效数值 = [(玩家基础数值 + 基础数值加成) x (1 + 基础数值倍率加成)] x (1 + 最终数值倍率加成)
-- FinalValue = [(PlayerValue + BaseValue) x (1 + BaseFactor)] x (1 + FinalFactor)
-- 公式中的 BaseValue, BaseFactor, FinalFactor
-- 对应配置 ValueName1, ValueName2, ValueName3, DisplayValueName, ValueName 为具体属性名