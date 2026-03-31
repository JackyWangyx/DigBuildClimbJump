local ObjectPool = {}

-- 每个 prefab 的池缓存
local Cache = {}
-- 实例对应的池
local InstanceToPoolMap = {}
-- 全池统计
ObjectPool.TotalSpawned = 0
ObjectPool.TotalActive = 0
ObjectPool.TotalDeactive = 0
-- 默认单池最大容量
ObjectPool.DefaultMaxPoolSize = 1000

-- 获取或创建池
function ObjectPool:GetPool(prefab)
	local pool = Cache[prefab]
	if not pool then
		pool = {
			ActiveList = {},
			DeActiveList = {},
			MaxSize = self.DefaultMaxPoolSize
		}
		Cache[prefab] = pool
	end
	return pool
end

-- 设置池容量限制
function ObjectPool:SetPoolMaxSize(prefab, maxSize)
	local pool = self:GetPool(prefab)
	pool.MaxSize = maxSize
end

-- 生成对象
function ObjectPool:Spawn(prefab)
	if not prefab then return end
	local pool = self:GetPool(prefab)
	local instance

	if #pool.DeActiveList > 0 then
		instance = table.remove(pool.DeActiveList)
		ObjectPool.TotalDeactive = ObjectPool.TotalDeactive - 1
	else
		instance = prefab:Clone()
		ObjectPool.TotalSpawned = ObjectPool.TotalSpawned + 1
	end

	table.insert(pool.ActiveList, instance)
	InstanceToPoolMap[instance] = pool
	ObjectPool.TotalActive = ObjectPool.TotalActive + 1

	return instance
end

-- 回收对象
function ObjectPool:DeSpawn(instance)
	if not instance then return end
	local pool = InstanceToPoolMap[instance]
	if not pool then
		-- 没有池信息，直接销毁
		instance:Destroy()
		return
	end

	-- 从 ActiveList 移除
	for i = 1, #pool.ActiveList do
		if pool.ActiveList[i] == instance then
			pool.ActiveList[i] = pool.ActiveList[#pool.ActiveList]
			table.remove(pool.ActiveList)
			ObjectPool.TotalActive = ObjectPool.TotalActive - 1
			break
		end
	end

	-- 超过池容量直接销毁
	if #pool.DeActiveList >= pool.MaxSize then
		instance:Destroy()
		InstanceToPoolMap[instance] = nil
		ObjectPool.TotalSpawned = ObjectPool.TotalSpawned - 1
	else
		instance.Parent = nil
		table.insert(pool.DeActiveList, instance)
		ObjectPool.TotalDeactive = ObjectPool.TotalDeactive + 1
		InstanceToPoolMap[instance] = nil
	end
end

-- 获取已生成对象数量（Active + Deactive）
function ObjectPool:GetSpawnedCount(prefab)
	local pool = Cache[prefab]
	if not pool then return 0 end
	return #pool.ActiveList + #pool.DeActiveList
end

-- 清空单个 prefab 池
function ObjectPool:Clear(prefab)
	local pool = Cache[prefab]
	if pool then
		for _, instance in ipairs(pool.ActiveList) do
			instance:Destroy()
			ObjectPool.TotalActive = ObjectPool.TotalActive - 1
			ObjectPool.TotalSpawned = ObjectPool.TotalSpawned - 1
			InstanceToPoolMap[instance] = nil
		end
		for _, instance in ipairs(pool.DeActiveList) do
			instance:Destroy()
			ObjectPool.TotalDeactive = ObjectPool.TotalDeactive - 1
			ObjectPool.TotalSpawned = ObjectPool.TotalSpawned - 1
		end
	end
	Cache[prefab] = nil
end

-- 清空所有池
function ObjectPool:ClearAll()
	for prefab, pool in pairs(Cache) do
		for _, instance in ipairs(pool.ActiveList) do
			instance:Destroy()
		end
		for _, instance in ipairs(pool.DeActiveList) do
			instance:Destroy()
		end
	end
	Cache = {}
	InstanceToPoolMap = {}
	ObjectPool.TotalSpawned = 0
	ObjectPool.TotalActive = 0
	ObjectPool.TotalDeactive = 0
end

return ObjectPool
