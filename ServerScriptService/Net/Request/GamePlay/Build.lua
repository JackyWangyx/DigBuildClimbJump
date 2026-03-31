local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local BuildDefine = require(game.ReplicatedStorage.ScriptAlias.BuildDefine)
local BuildUtil = require(game.ReplicatedStorage.ScriptAlias.BuildUtil)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)

local Define = require(game.ReplicatedStorage.Define)

local Build = {}

local SaveInfoTemplate = {
	PackagePartList = {
		[1] = {
			ID = 1,
			Count = 1,
		}
	},
	BlueprintList = {
		[1] = {
			Key = "",
			PartList = {
				[1] = {
					ID = 1,
					PosKey = "1_1_1",
					Direction = BuildDefine.DirectionType.Front,
				}
			},
		}
	},
	Store = {
		LastRefreshTime = 0,
		PartList = {
			[1] = {
				ID = 1,
				Count = 1,
			}
		},
	},
}

function LoadInfo(player)
	local saveInfo = PlayerPrefs:GetModule(player, "Build")
	return saveInfo
end

-- Part

function Build:GetPackagePartList(player, param)
	local saveInfo = LoadInfo(player)
	local partList = saveInfo.PackagePartList
	if not partList then
		partList = {}
		saveInfo.PackagePartList = partList
	end
	
	return partList
end

function Build:GetPackagePartInfo(player, param)
	local id = param.ID
	local partList = Build:GetPackagePartList(player)
	local partInfo = Util:ListFind(partList, function(info)
		return info.ID == id
	end)

	if not partInfo then
		partInfo = {
			ID = id,
			Count = 0
		}
		
		table.insert(partList, partInfo)
	end
	
	return partInfo
end

function Build:AddPart(player, param)
	local count = param.Count or 1
	local partInfo = Build:GetPackagePartInfo(player, { ID = param.ID } )
	partInfo.Count += count	
	EventManager:DispatchToClient(player, EventManager.Define.RefreshBuildPartList)
	return true
end

function Build:RemovePart(player, param)
	local count = param.Count or 1
	local partInfo = Build:GetPackagePartInfo(player, { ID = param.ID } )
	if partInfo.Count >= count then
		partInfo.Count -= count
		EventManager:DispatchToClient(player, EventManager.Define.RefreshBuildPartList)
		return true
	else
		return false
	end
end

-- Blueprint

function Build:GetBlueprintList(player, param)
	local saveInfo = LoadInfo(player)
	local blueprintList = saveInfo.BlueprintList
	if not blueprintList then
		blueprintList = {}
		saveInfo.BlueprintList = blueprintList
	end

	return blueprintList
end

function Build:GetBlueprint(player, param)
	local key = param.Key or "Default"
	local blueprintList = Build:GetBlueprintList(player)
	local blueprint = Util:ListFind(blueprintList, function(info)
		return info.Key == key
	end)

	if not blueprint then
		blueprint = {
			Key = key,
			PartList = {}
		}

		table.insert(blueprintList, blueprint)
	end

	return blueprint
end

function Build:SetBlueprintPartList(player, param)
	local key = param.Key or "Default"
	local partList = param.PartList
	local blueprint = Build:GetBlueprint(player, { Key = key })
	blueprint.PartList = partList
	return true
end

function Build:RemoveBlueprint(player, param)
	local key = param.Key or "Default"
	local blueprintList = Build:GetBlueprintList(player)
	local blueprint = Util:ListFind(blueprintList, function(info)
		return info.Key == key
	end)
	
	if blueprint then
		Util:ListRemove(blueprintList, blueprint)
	end
	
	return true
end

-- Build

function Build:SetBlueprintPart(player, param)
	local key = param.Key or "Default"
	local partID = param.PartID
	local posKey = param.PosKey
	local direction = param.Direction
	
	-- 库存零件不足
	local packagePartInfo = Build:GetPackagePartInfo(player, { ID = partID })
	if packagePartInfo.Count <= 0 then
		return {
			Success = false,
			Message = "Part not enough !",
		}
	end
	
	local blueprint = Build:GetBlueprint(player, { Key = key })
	local buildPartInfo = blueprint.PartList[posKey]
	
	-- 位置已经被占用
	if buildPartInfo then
		return {
			Success = false,
			Message = "Exist part !",
		}
	else
		packagePartInfo.Count -= 1
		
		buildPartInfo = {
			ID = partID,
			Direction = direction,
		}
		
		blueprint.PartList[posKey] = buildPartInfo
	end
	
	EventManager:DispatchToClient(player, EventManager.Define.RefreshBuildPartList)
	
	return {
		Success = true,
		Message = "",
	}
end

function Build:RemoveBlueprintPart(player, param)
	local key = param.Key or "Default"
	local posKey = param.PosKey
	
	local blueprint = Build:GetBlueprint(player, { Key = key })
	local buildPartInfo = blueprint.PartList[posKey]
	
	if not buildPartInfo then
		return {
			Success = false,
			Message = "Empty !",
		}
	else
		local partID = buildPartInfo.ID
		local packagePartInfo = Build:GetPackagePartInfo(player, { ID = partID })
		packagePartInfo.Count += 1
		blueprint.PartList[posKey] = nil
		
		EventManager:DispatchToClient(player, EventManager.Define.RefreshBuildPartList)
		return {
			Success = true,
			Message = "",
		}
	end
end

return Build
