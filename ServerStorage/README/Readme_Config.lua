-- [⚙ 配置表]

-- 路径 : ServerStorage/Config
-- 文件名 : XXXXConfig
-- 数值 : 无效数值，数字填 0，字符串填 nil，不能留空

---------------------------------------------------------------------------------------------------------------------------

-- [⚙ 配置表 <-> UI 对应关系]

-- Info_ValueName : Value 为有效值时节点打开
-- Text_ValueName : 显示 Value 的数值
-- Text_ValueName_F2 : 数值类型显示成保留2位小数
-- Text_ValueName_BigNumber : 以大数形式显示 Value 数值
-- Text_DisplayValueName : 显示 Value 对应的自定义样式 DisplayValue 内容
-- Enum_Rarity_1 : 枚举类型所有对应属性开头的节点，只有数值相同的会打开，其余会关闭

---------------------------------------------------------------------------------------------------------------------------

-- [⚙ 配置表 - 通用奖励 & 奖励包 配置 ]
-- 参数：RewardType, RewardID, RewardCount
-- RewardID 一般为对应的道具表中的 ID，Power, Coin 等类型 ID 无效.
-- 奖励包：如果类型为 Pacakge, 则具体奖励内容，会查找 "RewardPacakgeConfig" 表中, PackageID == RewardID 的所有行，并分别发放。
-- 基础属性加成：Property1，此时 RewardID 为属性名，RewardCount 为属性增加值
-- [弃用]最终属性加成：Property3，此时 RewardID 为属性名，RewardCount 为属性增加值

-- [可选类型]
-- RewardPacakge
-- Pet
-- PetPackage
-- PetEquip
-- Animal
-- AnimalPackage
-- AnimalEquip
-- Partner
-- Prop
-- Coin
-- Wins
-- Power
-- Tool
-- Trail
-- LuckyWheel
-- PassPoint
-- Property1
-- Property2
-- Property3
-- PetLoot
