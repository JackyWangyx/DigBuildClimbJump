local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local ModelUtil = {}

local ModelCacheData = {}

function ModelUtil:CacheModelData(model)
	ModelCacheData[model] = {}
	local cacheData = ModelCacheData[model]
	local pivotCFrame = model:GetPivot()
	for _, part in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			cacheData[part] = {
				Offset = pivotCFrame:ToObjectSpace(part.CFrame),
				Size = part.Size
			}
		end
	end
	
	model.AncestryChanged:Connect(function()
		if not model.Parent then
			ModelCacheData[model] = nil
		end
	end)
end

function ModelUtil:SetScale(model, scaleVector)
	local cacheData = ModelCacheData[model]
	if not cacheData then
		ModelUtil:CacheModelData(model)
		cacheData = ModelCacheData[model]
	end
	
	local currentCFrame = model:GetPivot()
	local originalPivotPosition = currentCFrame.Position
	for part, data in pairs(cacheData) do
		if part and part.Parent then
			part.Size =  Util:Vector3Multiply(data.Size, scaleVector)
			local newOffset = Util:Vector3Multiply(data.Offset.Position, scaleVector)
			part.CFrame = currentCFrame * CFrame.new(newOffset)  * (data.Offset - data.Offset.Position)
		end
	end

	local newPivotPosition = currentCFrame.Position + (originalPivotPosition - currentCFrame.Position) * (scaleVector - Vector3.one)
	local newPivot = CFrame.new(newPivotPosition) * CFrame.Angles(currentCFrame:ToEulerAnglesXYZ())
	model:PivotTo(newPivot)
	--local newPos = Util:Vector3Multiply(currentCFrame.Position, scaleVector)
	--local newPivot = CFrame.new(newPos) * CFrame.Angles(currentCFrame:ToEulerAnglesXYZ())
	--model:PivotTo(newPivot)
end

function ModelUtil:SetForward(model, forward)
	local newCFrame = CFrame.lookAt(model:GetPivot().Position, model:GetPivot().Position + forward)
	model:PivotTo(newCFrame)
end

function ModelUtil:SetRotation(model, rotation)
	local pivotCFrame = model:GetPivot()
	local cacheData = ModelCacheData[model]
	if not cacheData then
		ModelUtil:CacheModelData(model)
		cacheData = ModelCacheData[model]
	end

	for part, data in pairs(cacheData) do
		if part and part.Parent then
			local position = part.Position
			part.CFrame = CFrame.fromEulerAnglesXYZ(math.rad(rotation.x), math.rad(rotation.y), math.rad(rotation.z)) -- CFrame.new(position) * 
			part.Position = position
		end
	end
end

--local currentCFrame = model:GetPivot()
--part.CFrame = CFrame.new(newOffset) * data.Offset - data.Offset.Position
--local scaleOffset = CFrame.new(newOffset) * (data.Offset - data.Offset.Position)
--part.CFrame = currentCFrame * scaleOffset
--part.Orientation = rotation

return ModelUtil
