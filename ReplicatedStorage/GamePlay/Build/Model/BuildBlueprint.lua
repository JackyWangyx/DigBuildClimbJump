local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)

local BuildUtil = require(game.ReplicatedStorage.ScriptAlias.BuildUtil)
local BuildDefine = require(game.ReplicatedStorage.ScriptAlias.BuildDefine)

local BuildBlueprint = {}

BuildBlueprint.__index = BuildBlueprint

BuildBlueprint.Key = nil
BuildBlueprint.Blueprint = nil

function BuildBlueprint.new(blueprintKey)
	local self = setmetatable({}, BuildBlueprint)
	self.Key = blueprintKey or "Default"
	self:Load()
	return self
end

function BuildBlueprint:Load()
	local saveInfo = NetClient:RequestWait("Build", "GetBlueprint", { 
		Key = self.Key 
	})
	
	self.Blueprint = saveInfo
end

function BuildBlueprint:CheckCanSet(x, y, z)
	if not self.Blueprint then return false end
	local posKey = BuildUtil:GetKey(x, y, z)
	local partInfo = self.Blueprint.PartList[posKey]
	return partInfo == nil
end

function BuildBlueprint:GetPart(x, y, z)
	if not self.Blueprint then return nil end
	local posKey = BuildUtil:GetKey(x, y, z)
	local partInfo = self.Blueprint.PartList[posKey]
	return partInfo
end

function BuildBlueprint:GetPartList()
	if not self.Blueprint then return {} end
	return self.Blueprint.PartList
end

function BuildBlueprint:SetPart(x, y, z, partID , direction)
	if not self.Blueprint then return end
	local posKey = BuildUtil:GetKey(x, y, z)
	local result = NetClient:RequestWait("Build", "SetBlueprintPart", { 
		Key = self.Key,
		PartID = partID,
		PosKey = posKey,
		Direction = direction,
	})
	
	if result.Success then
		self.Blueprint.PartList[posKey] = {
			ID = partID,
			Direction = direction,
		}
		
		return true
	else
		return false
	end
end

function BuildBlueprint:RemovePart(x, y, z)
	if not self.Blueprint then return end
	local posKey = BuildUtil:GetKey(x, y, z)
	local result = NetClient:RequestWait("Build", "RemoveBlueprintPart", { 
		Key = self.Key,
		PosKey = posKey,
	})
	
	if result.Success then
		self.Blueprint.PartList[posKey] = nil
		return true
	else
		return false
	end
end

return BuildBlueprint
