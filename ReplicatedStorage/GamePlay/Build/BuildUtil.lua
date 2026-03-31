local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local BuildDefine = require(game.ReplicatedStorage.ScriptAlias.BuildDefine)

local BuildUtil = {}

-- Base

function BuildUtil:GetKey(x, y, z)
	return x..","..y..","..z
end

function BuildUtil:GetPosFromKey(key)
	local parts = string.split(key, ",")
	local x = tonumber(parts[1])
	local y = tonumber(parts[2])
	local z = tonumber(parts[3])
	return x, y, z
end

function BuildUtil:GetPos(x, y, z)
	local cellSize = BuildDefine.CellSize
	local sizeX = BuildDefine.WorkSpaceSize.X
	local sizeY = BuildDefine.WorkSpaceSize.Y
	local sizeZ = BuildDefine.WorkSpaceSize.Z

	local center = BuildDefine.InitPos
	local startX = center.X - (sizeX * cellSize) / 2 + cellSize / 2
	local startY = center.Y + 0.2
	local startZ = center.Z - (sizeZ * cellSize) / 2 + cellSize / 2

	local x = startX + (x - 1) * cellSize
	local y = startY + (y - 1) * cellSize
	local z = startZ + (z - 1) * cellSize
	local pos = Vector3.new(x, y, z)
	return pos
end

function BuildUtil:Forech(callback)
	if not callback then return end
	for x = 1, BuildDefine.WorkSpaceSize.X do
		for z = 1, BuildDefine.WorkSpaceSize.Z do
			for y = 1, BuildDefine.WorkSpaceSize.Y do
				callback(x, y, z)
			end
		end
	end
end

function BuildUtil:ForechNeighbour(x, y, z, callback)
	if not callback then return end
	local neighbours = {
		{x + 1, y, z},
		{x - 1, y, z},
		{x, y + 1, z},
		{x, y - 1, z},
		{x, y, z + 1},
		{x, y, z - 1},
	}
	for _, pos in ipairs(neighbours) do
		local nx, ny, nz = pos[1], pos[2], pos[3]
		if nx >= 1 and nx <= BuildDefine.WorkSpaceSize.X and
			ny >= 1 and ny <= BuildDefine.WorkSpaceSize.Y and
			nz >= 1 and nz <= BuildDefine.WorkSpaceSize.Z then
			callback(nx, ny, nz)
		end
	end
end

function BuildUtil:ForechNeighbourXZ(x, y, z, callback)
	if not callback then return end
	local neighbours = {
		{x + 1, y, z},
		{x - 1, y, z},
		{x, y, z + 1},
		{x, y, z - 1},
	}
	for _, pos in ipairs(neighbours) do
		local nx, ny, nz = pos[1], pos[2], pos[3]
		if nx >= 1 and nx <= BuildDefine.WorkSpaceSize.X and
			ny >= 1 and ny <= BuildDefine.WorkSpaceSize.Y and
			nz >= 1 and nz <= BuildDefine.WorkSpaceSize.Z then
			callback(nx, ny, nz)
		end
	end
end

-- Info

function BuildUtil:ProcessPartList(infoList)
	local result = {}
	for _, info in ipairs(infoList) do
		local id = info.ID
		if not id then continue end
		local count = info.Count
		if count and count == 0 then continue end
		local data = ConfigManager:GetData("BuildPart", id)
		Util:TableMerge(info, data)
		table.insert(result, info)
	end
	
	return result
end

-- CFrame

function BuildUtil:SetPartPosition(part, position)
	Util:SetPosition(part, position)
end

function BuildUtil:SetPartRotation(part, rotation)
	if typeof(rotation) == "number" then
		rotation = BuildDefine.DirectionRotation[rotation]
	end
	
	Util:SetRotation(part, rotation)
end


-- Effect

function BuildUtil:SetPartPhysics(part, active)
	for _, subPart in ipairs(part:GetDescendants()) do
		if subPart:IsA("BasePart") then
			subPart.Anchored = not active
			subPart.CanCollide = active
			subPart.CanTouch = active
			subPart.CanQuery = active
			subPart.Massless = not active
		end
	end
end

function BuildUtil:SetPartTransparency(part, alpha)
	for _, subPart in ipairs(part:GetDescendants()) do
		if subPart:IsA("BasePart") then
			subPart.Transparency = alpha
		end
	end
end

function BuildUtil:SetPartOutline(part, active)
	local highlight = part:FindFirstChild("Outline")
	if active then
		if not highlight then
			highlight = Instance.new("Highlight")
			highlight.Name = "Outline"
			highlight.Parent = part
			highlight.FillTransparency = 1
			highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
			highlight.Adornee = part
		end
	else
		if highlight then
			highlight:Destroy()
		end
	end
end

return BuildUtil
