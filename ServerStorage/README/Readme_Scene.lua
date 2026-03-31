-- [🏠 场景建筑 命名规范]

-- 建筑路径：WorkSpace/Buidling/
-- 建筑命名：BuildingXXXX， 必须以 Building 开头，且根节点为 Model 类型，其他所有非建筑对象和子节点不能以 Building 开头
-- 建筑代码：ReplicatedStorage/Module/BuildingXXXX
-- 建筑根节点下 Trigger 为建筑功能触发范围

---------------------------------------------------------------------------------------------------------------------------

-- [💰 内购]

-- IAPConfig 中配置
-- ProductKey 在游戏项目中调用，被其他商品配置引用
-- ProductID 开发者后台配置
-- 在具体配置中，需要 CostRobux 为非0数值，需要手动对应后台配置的价格，且 ProductKey 为非空字符串，在 IAPConfig 中可查

-- 通用商店内道具的 RB 购买
-- 每个商品对应的 ProductKey 命名为 ProductStoreTool01, ProductStore 为表示商店内购买的固定前缀, Tool 为商店配置名, 01 为商品 ID
-- 举例 ：ProductStoreTool01, ProductStoreTrail01 , ProductStorePet01

---------------------------------------------------------------------------------------------------------------------------