local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local SceneManager = require(game.ReplicatedStorage.ScriptAlias.SceneManager)
local SceneAreaManager = require(game.ReplicatedStorage.ScriptAlias.SceneAreaManager)
local ResourcesManager = require(game.ReplicatedStorage.ScriptAlias.ResourcesManager)
local Building = require(game.ReplicatedStorage.ScriptAlias.Building)

local BuildingManager = {}

BuildingManager.GlobalBuildingPath = nil
BuildingManager.AreaBuildingPathList = {}
BuildingManager.BuildingScriptCache = {}
BuildingManager.Count = 0

BuildingManager.BuildingList = {}

-----------------------------------------------------------------------------------------------------
-- Init

function BuildingManager:Init()	
	BuildingManager.GlobalBuildingPath = SceneManager.LevelRoot:WaitForChild("Building")
	if BuildingManager.GlobalBuildingPath then
		BuildingManager:InitPath(BuildingManager.GlobalBuildingPath, Building.Mode.Global, -1)
	end
	
	if SceneManager.AreaList then
		for areaIndex, areaInfo in ipairs(SceneAreaManager.AreaInfoList) do
			local areaBuildingPath = areaInfo.Area:FindFirstChild("Building")
			if areaBuildingPath then
				BuildingManager:InitPath(areaBuildingPath,  Building.Mode.Area, areaIndex)
				table.insert(BuildingManager.AreaBuildingPathList, areaBuildingPath)
			end
			
			if areaInfo.OnlySelf then
				local areaOnlySelfBuildingPath = areaInfo.OnlySelf:FindFirstChild("Building")
				if areaOnlySelfBuildingPath then
					BuildingManager:InitPath(areaOnlySelfBuildingPath,  Building.Mode.Area, areaIndex)
					table.insert(BuildingManager.AreaBuildingPathList, areaOnlySelfBuildingPath)
				end
			end	
			
			for themeIndex, themeInfo in ipairs(areaInfo.ThemeList) do
				local pathList = Util:GetAllChildByTypeAndName(themeInfo.Theme, "Folder", "Building", true)
				for _, path in ipairs(pathList) do
					table.insert(BuildingManager.AreaBuildingPathList, path)
					BuildingManager:InitPath(path, Building.Mode.Area, areaIndex)
				end
			end		
		end
	end
	
	--print("Building Load : ", BuildingManager.Count)
end

function BuildingManager:InitPath(path, mode, areaIndex)
	local children = path:GetDescendants()
	for _, child in ipairs(children) do
		if BuildingManager:IsBuilding(child) then
			BuildingManager:OnBuildingAdded(child, {
				Mode = mode,
				AreaIndex = areaIndex,
			})
		end
	end

	path.ChildAdded:Connect(function(part)
		if BuildingManager:IsBuilding(part) then
			BuildingManager:OnBuildingAdded(part, {
				Mode = mode,
				AreaIndex = areaIndex,
			})
		end
	end)
end

function BuildingManager:IsBuilding(part)
	local buildingName = part.Name
	if not Util:IsStrStartWith(buildingName, "Building") then
		return false
	end
	return true
end

function BuildingManager:OnBuildingAdded(buildingPart, opts)
	local buildingName = buildingPart.Name
	local buildingScriptFile = BuildingManager.BuildingScriptCache[buildingName]
	if not buildingScriptFile then
		buildingScriptFile = Util:GetChildByTypeAndName(game.ReplicatedStorage, "ModuleScript", buildingName, true, ResourcesManager.ReplicatedStorageCache.All)
		BuildingManager.BuildingScriptCache[buildingName] = buildingScriptFile	
	end
	
	local triggerPart = buildingPart:FindFirstChild("Trigger")
	opts.TriggerPart = triggerPart
	
	local buuldingInfo = {
		Name = buildingName,
		BuildingPart = buildingPart,
		--Position = buildingPart.Position,
		Options = opts,
		AreaIndex = opts.AreaIndex
	}
	
	if triggerPart then
		buuldingInfo.TriggerPart = triggerPart
		buuldingInfo.TriggerPos = triggerPart.Position
	end 
	
	if buildingScriptFile then
		local buildingScript = require(buildingScriptFile)
		local initFunc = buildingScript["Init"]
		if initFunc then
			initFunc(buildingScript, buildingPart, opts)
		end
	end
	
	table.insert(BuildingManager.BuildingList, buuldingInfo)
	BuildingManager.Count += 1
end

-----------------------------------------------------------------------------------------------------
-- Get

function BuildingManager:GetBuilding(buildingName)
	local isClient = RunService:IsClient()
	local currentAreaIndex = SceneAreaManager.CurrentAreaIndex
	for _, buildingInfo in ipairs(BuildingManager.BuildingList) do
		if buildingInfo.Name == buildingName then
			if isClient then
				if buildingInfo.AreaIndex > 0 and buildingInfo.AreaIndex == currentAreaIndex then 
					return buildingInfo
				end
			else
				return buildingInfo
			end
		end
	end
	
	return nil
end

return BuildingManager
