local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local BuildPart = require(game.ReplicatedStorage.ScriptAlias.BuildPart)
local BuildUtil = require(game.ReplicatedStorage.ScriptAlias.BuildUtil)
local BuildDefine = require(game.ReplicatedStorage.ScriptAlias.BuildDefine)

local BuildModel = {}

BuildModel.__index = BuildModel

--BuildModel.Root = nil
--BuildModel.BuildManager = nil
--BuildModel.Blueprint = nil
--BuildModel.PartList = {}

function BuildModel.new(buildManager, blueprint)
	local self = setmetatable({}, BuildModel)
	self.PartList = {}
	self.BuildManager = buildManager
	self.Root = Instance.new("Model")
	self.Root.Name = "Blueprint_"..blueprint.Key
	self.Root.Parent = game.Workspace
	if blueprint then
		self:Load(blueprint)
	end
	return self
end

-- Info

function BuildModel:Load(blueprint)
	self.Blueprint = blueprint
end

-- Update

function BuildModel:Update(deltaTime)
	for _, buildPart in pairs(self.PartList) do
		buildPart:Update(deltaTime)
	end
end

-- Model

function BuildModel:SpawnModel()
	BuildUtil:Forech(function(x, y, z)
		local partInfo = self.Blueprint:GetPart(x, y, z)
		if partInfo then
			self:SpawnPart(x, y, z, partInfo.ID, partInfo.Direction)
		end
	end)
end

function BuildModel:SpawnPart(x, y, z, partID, direction)
	local posKey = BuildUtil:GetKey(x, y, z)
	local partData = ConfigManager:GetData("BuildPart", partID)
	local prefab = Util:LoadPrefab(partData.Prefab)
	local part = prefab:Clone()
	part.Parent = self.Root
	part.Name = "Part_"..posKey.."_"..partData.Type
	BuildUtil:SetPartPhysics(part, false)
	local position = BuildUtil:GetPos(x, y, z)
	BuildUtil:SetPartPosition(part, position)
	BuildUtil:SetPartRotation(part, direction)
	self.PartList[posKey] = part
end

function BuildModel:DeSpawnModel()
	BuildUtil:Forech(function(x, y, z)
		self:DeSpawnPart(x, y, z)
	end)
end

function BuildModel:DeSpawnPart(x, y, z)
	local posKey = BuildUtil:GetKey(x, y, z)
	local part = self:GetPart(x, y, z)
	if part then
		part:Destroy()
		self.PartList[posKey] = nil
	end
end

function BuildModel:RefreshModel()
	self:DeSpawnModel()
	self:SpwanModel()
end

-- Check

function BuildModel:CheckCanSet(x, y, z)
	local part = self:GetPart(x, y, z)
	local downPart = self:GetPart(x, y - 1, z)
	local c1 = part == nil
	local c2 = y == 1 or downPart ~= nil
	local c3 = self.Blueprint:CheckCanSet(x, y, z)
	local result = c1 and c2 and c3
	return result
end

function BuildModel:CheckExist(x, y, z)
	local part = self:GetPart(x, y, z)
	return part ~= nil
end

-- Part

function BuildModel:SetPart(x, y, z, partID, direction)
	local success = self.Blueprint:SetPart(x, y, z, partID, direction)	
	if success then
		self:SpawnPart(x, y, z, partID, direction)
	end	
end

function BuildModel:RemovePart(x, y, z)
	local success = self.Blueprint:RemovePart(x, y, z)	
	if success then
		self:DeSpawnPart(x, y, z)
	end
end

function BuildModel:GetPartList(x, y, z)
	return self.PartList
end

function BuildModel:GetPart(x, y, z)
	local posKey = BuildUtil:GetKey(x, y, z)
	local part = self.PartList[posKey]
	return part
end

return BuildModel