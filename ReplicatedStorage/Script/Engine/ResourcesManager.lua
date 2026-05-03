local RunService = game:GetService("RunService")

local ResourcesManager = {}

local PreLoadPrefabCache = {}

ResourcesManager.PrefabRootPath = game.ReplicatedStorage.Prefab

ResourcesManager.ReplicatedStorageCache = {
	--All = nil,
	Script = {},
}

function ResourcesManager:Init()
	ResourcesManager:LoadReplicatedStorage()
end

----------------------------------------------------------------------------------------------------------------
-- Script

function ResourcesManager:GetScript(scrptName)
	local scriptCache = ResourcesManager.ReplicatedStorageCache.Script
	local result = scriptCache[scrptName]
	if not result then
		local util = require(game.ReplicatedStorage.ScriptAlias.Util)
		result = util:GetChildByTypeAndName(game.ReplicatedStorage, "ModuleScript", scrptName, true)
		if result then
			scriptCache[scrptName] = result
		end
	end
	
	return result
end

----------------------------------------------------------------------------------------------------------------
-- Prefab

function ResourcesManager:LoadReplicatedStorage()
	local isWorking = true
	task.spawn(function()
		local scriptCache = ResourcesManager.ReplicatedStorageCache.Script
		local cacheScript = function(partList)
			for _, child in ipairs(partList) do
				scriptCache[child.Name] = child
			end	
		end
		
		cacheScript(game.ReplicatedStorage.Module:GetDescendants())
		cacheScript(game.ReplicatedStorage.Script:GetDescendants())
		
		if RunService:IsClient() then
			cacheScript(game.ReplicatedStorage.GamePlay:GetDescendants())
		else
			cacheScript(game.ServerScriptService.Net:GetDescendants())
			cacheScript(game.ServerScriptService.GamePlay:GetDescendants())
			cacheScript(game.ServerScriptService.Module:GetDescendants())
			
			cacheScript(game.ServerStorage.Config:GetDescendants())
			cacheScript(game.ServerStorage.ConfigLevel:GetDescendants())
		end
		
		isWorking = false
	end)

	while isWorking do
		task.wait()
	end
end

local PathCache = {}

local function ParsePath(path: string)
	if PathCache[path] then
		return PathCache[path]
	end

	local parts = string.split(path, "/")
	PathCache[path] = parts
	return parts
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
	table.clear(PreLoadPrefabCache)
	table.clear(PathCache)
end

function ResourcesManager:Load(path)
	if not path or path == "" then
		return nil
	end

	local cached = PreLoadPrefabCache[path]
	if cached ~= nil then
		return cached
	end

	local result = ResourcesManager:LoadImpl(path)

	if result then
		PreLoadPrefabCache[path] = result
	end

	return result
end

function ResourcesManager:LoadImpl(path)
	local current = ResourcesManager.PrefabRootPath
	local parts = ParsePath(path)

	for i = 1, #parts do
		current = current:FindFirstChild(parts[i])
		if not current then
			return nil
		end
	end

	return current
end

----------------------------------------------------------------------------------------------------------------
-- Instance

local function GetInstanceByPath(startInstance: Instance, path: string): Instance?
	if not startInstance or not path or path == "" then
		return nil
	end

	local current = startInstance
	local parts = ParsePath(path)

	for i = 1, #parts do
		current = current:FindFirstChild(parts[i])
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
	if not playerGui then
		return nil
	end

	local showFolder = playerGui:FindFirstChild("Show")
	local hideFolder = playerGui:FindFirstChild("Hide")

	local result = GetInstanceByPath(showFolder, path)
	if result then return result end

	return GetInstanceByPath(hideFolder, path)
end

----------------------------------------------------------------------------------------------------------------
-- Part

function ResourcesManager:GetPartByPath(path: string): BasePart?
	local instance = GetInstanceByPath(game.Workspace, path)
	return instance
end

return ResourcesManager
