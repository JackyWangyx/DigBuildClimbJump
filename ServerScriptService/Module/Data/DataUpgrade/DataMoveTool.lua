local DataStoreService = game:GetService("DataStoreService")

local DataMoveTool = {}

function DataMoveTool:Get(dataStore, key)
	local success, result = pcall(function()
		local store = DataStoreService:GetDataStore(dataStore)
		local value = store:GetAsync(key)
		return value
	end)

	if not success then
		warn("[Data Move] Get Fail! ", dataStore, key, debug.traceback(result, 2))
		return nil
	else
		return result
	end
end

function DataMoveTool:Set(dataStore, key, value)
	local success, result = pcall(function()
		local store = DataStoreService:GetDataStore(dataStore)
		store:SetAsync(key, value)
	end)

	if not success then
		warn("[Data Move] Set Fail! ", dataStore, key, debug.traceback(result, 2))
	end
end

function DataMoveTool:Remove(dataStore, key, value)
	local success, result = pcall(function()
		local store = DataStoreService:GetDataStore(dataStore)
		store:RemoveAsync(key)
	end)

	if not success then
		warn("[Data Move] Remove Fail! ", dataStore, key, debug.traceback(result, 2))
	end
end

function DataMoveTool:Move(fromDataStore, fromKey, toDataStore, toKey)
	local success, result = pcall(function()
		local fromStore = DataStoreService:GetDataStore(fromDataStore)
		local toStore = DataStoreService:GetDataStore(fromDataStore)

		local fromValue = fromStore:GetAsync(fromKey)
		toStore:SetAsync(toKey, fromValue)
		
		print("[Data Move] Move Success : ", fromDataStore, fromKey, toDataStore, toKey, fromValue)
	end)

	if not success then
		warn("[Data Move] Move Fail! ", fromDataStore, fromKey, toDataStore, toKey, debug.traceback(result, 2))
	end
end

return DataMoveTool
