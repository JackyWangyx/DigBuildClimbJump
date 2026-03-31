local UserInputService = game:GetService("UserInputService")

local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local MouseUtil = require(game.ReplicatedStorage.ScriptAlias.MouseUtil)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local BuildBlueprint = require(game.ReplicatedStorage.ScriptAlias.BuildBlueprint)
local BuildModel = require(game.ReplicatedStorage.ScriptAlias.BuildModel)
local BuildCell = require(game.ReplicatedStorage.ScriptAlias.BuildCell)
local BuildUtil = require(game.ReplicatedStorage.ScriptAlias.BuildUtil)
local BuildDefine = require(game.ReplicatedStorage.ScriptAlias.BuildDefine)

local BuildManager = {}

BuildManager.BuildArea = nil
BuildManager.BuildCell = {}
BuildManager.Phase = BuildDefine.BuildPhase.Disable

BuildManager.Blueprint = nil
BuildManager.BuildModel = nil

BuildManager.CurrentPart = nil
BuildManager.CurrentPartData = nil
BuildManager.CurrentDirection = BuildDefine.DirectionType.Front

--local carPrefab = game.ReplicatedStorage.Module.Drive.Car
--local car = carPrefab:Clone()
--car.Parent = game.Workspace

-- Init

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end  
	if input.KeyCode == Enum.KeyCode.R then
		BuildManager:RotatePart()
	end
end)

function BuildManager:Init()
	BuildManager.BuildArea = BuildDefine.PrefabPath.BuildArea:Clone()
	BuildManager.BuildArea.Parent = game.Workspace
	Util:SetPosition(BuildManager.BuildArea, BuildDefine.InitPos)
	BuildManager:InitGround()
	BuildManager:InitWorkSpace()
end

function BuildManager:InitGround()
	local groundPrefab1 = BuildDefine.PrefabPath.Ground.GroundPart1
	local groundPrefab2 = BuildDefine.PrefabPath.Ground.GroundPart2
	local groundParent = BuildManager.BuildArea:FindFirstChild("Ground")

	for x = 1, BuildDefine.WorkSpaceSize.X do
		for z = 1, BuildDefine.WorkSpaceSize.Z do
			local prefab = ((x + z) % 2 == 0) and groundPrefab1 or groundPrefab2
			local part = prefab:Clone()
			part.Name = "Ground_"..tostring(x)..","..tostring(z)
			part.Position = BuildUtil:GetPos(x, 0, z) + Vector3.new(0, BuildDefine.CellSize / 2, 0)
			part.Parent = groundParent
			part.Anchored = true
		end
	end
end

function BuildManager:InitWorkSpace()
	local buildCellPrefab = BuildDefine.PrefabPath.BuildCell
	local cellParent = BuildManager.BuildArea:FindFirstChild("WorkSpace")
	BuildUtil:Forech(function(x, y, z)
		local cellPart = buildCellPrefab:Clone()
		local key = BuildUtil:GetKey(x, y, z)
		cellPart.Name = "Cell_"..BuildUtil:GetKey(x, y, z)
		cellPart.Position = BuildUtil:GetPos(x, y, z)
		cellPart.Parent = cellParent
		cellPart.Anchored = true
		local cellInfo = {
			Part = cellPart,
			Parent = cellParent,
			X = x,
			Y = y,
			Z = z,
		}

		local cell = BuildCell.new(self, cellInfo)
		BuildManager.BuildCell[key] = cell
	end)
end

-- Build Cell

function BuildManager:GetCell(x, y, z)
	local key = BuildUtil:GetKey(x, y, z)
	return BuildManager.BuildCell[key]
end

function BuildManager:RefreshBuildCell()
	BuildUtil:Forech(function(x, y, z)
		local cell = BuildManager:GetCell(x, y, z)
		if BuildManager.Phase == BuildDefine.BuildPhase.Edit then
			local canSet = BuildManager.BuildModel:CheckCanSet(x, y, z)
			if canSet then
				cell:Enable()
			else
				cell:Disable()
			end
		elseif BuildManager.Phase == BuildDefine.BuildPhase.Remove then
			local exist = BuildManager.BuildModel:CheckExist(x, y, z)
			if exist then
				cell:Enable()
			else
				cell:Disable()
			end
		else
			cell:Disable()
		end
	end)
end

-- Build Blueprint

function BuildManager:LoadBlueprint(key)
	local buildBlueprint = BuildBlueprint.new(key)
	return buildBlueprint
end

-- Build Phase

function BuildManager:BuildStart()
	BuildManager.Blueprint = BuildManager:LoadBlueprint("Default")
	BuildManager.BuildModel = BuildModel.new(self, BuildManager.Blueprint)
	BuildManager.BuildModel:SpawnModel()
	
	BuildManager.CurrentPartData = nil
	BuildManager.CurrentPart = nil
	BuildManager.CurrentDirection = BuildDefine.DirectionType.Front
	
	BuildManager:SetPhase(BuildDefine.BuildPhase.Edit)
end

function BuildManager:SetPhase(buildPhase)
	if BuildManager.Phase == buildPhase then return end
	local previewPhase = BuildManager.Phase
	BuildManager.Phase = buildPhase
	if buildPhase == BuildDefine.BuildPhase.Edit then
		-- Edit
		if previewPhase == BuildDefine.BuildPhase.Disable then
			-- Start
			EventManager:Dispatch(EventManager.Define.BuildStart)
			UIManager:Cover("Build")
		end
		
		BuildManager:SpawnPreviewPart()
	elseif buildPhase == BuildDefine.BuildPhase.Remove then
		-- Remove
		BuildManager:DeSpawnPreviewPart()
	elseif buildPhase == BuildDefine.BuildPhase.Disable then
		-- End
		if BuildManager.CurrentPart then
			BuildManager.CurrentPart:Destroy()
		end
		
		EventManager:Dispatch(EventManager.Define.BuildEnd)
	end
	
	BuildManager:RefreshBuildCell()
	EventManager:Dispatch(EventManager.Define.SwitchBuildPhase, buildPhase)	
end

function BuildManager:BuildEnd()
	BuildManager:SetPhase(BuildDefine.BuildPhase.Disable)
end

-- Select Part

function BuildManager:SpawnPreviewPart()
	local partData = BuildManager.CurrentPartData
	if not partData then return end
	if BuildManager.CurrentPart then
		BuildManager.CurrentPart:Destroy()
	end
	
	local partPrefab = Util:LoadPrefab(partData.Prefab)
	local part = partPrefab:Clone()
	part.Name = "Part_Preview"
	part.Parent = game.Workspace
	BuildUtil:SetPartPhysics(part, false)
	BuildUtil:SetPartTransparency(part, 0.25)

	BuildManager.CurrentPart = part
	BuildManager.CurrentDirection = BuildDefine.DirectionType.Front
end

function BuildManager:DeSpawnPreviewPart()
	if BuildManager.CurrentPart then
		BuildManager.CurrentPart:Destroy()
		BuildManager.CurrentPart = nil
	end
end

function BuildManager:SelectPart(partData)
	if not partData then 
		BuildManager:DeSpawnPreviewPart()
		BuildManager.CurrentPartData = nil	
		return
	end
	
	local oldPartData = BuildManager.CurrentPartData
	BuildManager.CurrentPartData = partData
	
	if oldPartData and oldPartData.ID == partData.ID then
		return
	end
	
	BuildManager:DeSpawnPreviewPart()
	BuildManager:SpawnPreviewPart()
end

function BuildManager:RotatePart()
	if BuildManager.Phase ~= BuildDefine.BuildPhase.Edit then return end
	if not BuildManager.CurrentPart then return end
	BuildManager.CurrentDirection += 1
	if BuildManager.CurrentDirection > 4 then
		BuildManager.CurrentDirection = 1
	end
	
	BuildUtil:SetPartRotation(BuildManager.CurrentPart, BuildDefine.DirectionRotation[BuildManager.CurrentDirection])
end

-- Eidt Part

function BuildManager:SetPart(x, y, z)
	if not BuildManager.CurrentPartData then return end
	local partData = BuildManager.CurrentPartData
	local partID = partData.ID
	BuildManager.BuildModel:SetPart(x, y, z, partID, BuildManager.CurrentDirection)
	BuildManager:RefreshBuildCell()
	return true
end

function BuildManager:RemovePart(x, y, z)
	BuildManager.BuildModel:RemovePart(x, y, z)
	BuildManager:RefreshBuildCell()
	return true
end

return BuildManager
