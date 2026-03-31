local ResourcesManager = {}

local PreLoadPrefabCache = {}

ResourcesManager.ReplicatedStorageCache = {
	All = nil,
	Module = nil,
	Script = nil,
	GamePlay = nil,
}

function ResourcesManager:Init()
	ResourcesManager:LoadReplicatedStorage()
end

----------------------------------------------------------------------------------------------------------------
-- Prefab

function ResourcesManager:LoadReplicatedStorage()
	local isWorking = true
	task.spawn(function()
		ResourcesManager.ReplicatedStorageCache.All =  game.ReplicatedStorage:GetDescendants()
		ResourcesManager.ReplicatedStorageCache.Module =  game.ReplicatedStorage.Module:GetDescendants()
		ResourcesManager.ReplicatedStorageCache.Script =  game.ReplicatedStorage.Script:GetDescendants()
		ResourcesManager.ReplicatedStorageCache.GamePlay =  game.ReplicatedStorage.GamePlay:GetDescendants()
		isWorking = false
	end)

	while isWorking do
		task.wait()
	end
end

function ResourcesManager:PreLoadByPath(path)
	ResourcesManager:Load(path)
end

function ResourcesManager:PreLoadByPathList(pathList)
	for _, path in pairs(pathList) do
		ResourcesManager:PreLoadByPath(path)
	end
end

function ResourcesManager:ClearCache()
	PreLoadPrefabCache = {}
end

function ResourcesManager:Load(path)
	local cacheResources = PreLoadPrefabCache[path]
	if cacheResources then return cacheResources end	
	local result = ResourcesManager:LoadImpl(path)
	PreLoadPrefabCache[path] = result
	return result
end

function ResourcesManager:LoadImpl(path)
	local parts = string.split(path, '/')
	local current = game.ReplicatedStorage.Prefab
	for _, part in ipairs(parts) do
		current = current:FindFirstChild(part)
		if not current then
			return nil
		end
	end

	return current
end

local function GetInstanceByPath(startInstance: Instance, path: string): Instance?
	if not startInstance or path == "" then
		return nil
	end

	local current = startInstance
	local pathArray = string.split(path, '/')
	for index, subPath in pathArray do
		current = current:FindFirstChild(subPath)
		if not current then
			return nil
		end
	end

	return current
end

----------------------------------------------------------------------------------------------------------------
-- UI

function ResourcesManager:GetGuiByPath(path: string): Instance?
	local player = game.Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui", 10)
	if not playerGui then return nil end

	local showFolder = playerGui:FindFirstChild("Show")
	local hideFolder = playerGui:FindFirstChild("Hide")
	local result = GetInstanceByPath(showFolder, path)
	if not result then
		result = GetInstanceByPath(hideFolder, path)
	end
	
	return result
end

----------------------------------------------------------------------------------------------------------------
-- Part

function ResourcesManager:GetPartByPath(path: string): BasePart?
	local instance = GetInstanceByPath(game.Workspace, path)
	return instance
end

return ResourcesManager
