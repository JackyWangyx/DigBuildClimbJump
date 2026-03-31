local ProximityArea = require(game.ReplicatedStorage.ScriptAlias.ProximityArea)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local Building = require(game.ReplicatedStorage.ScriptAlias.Building)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local Define = require(game.ReplicatedStorage.Define)

local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local RotationSpeed = 0

local BuildingToolIAP = {}

function BuildingToolIAP:Handle(buildingPart, opts, toolID)
	local building = Building.Proximity(buildingPart, opts, Define.Message.BuyToolTip, function()
		local toolData = ConfigManager:GetData("Tool", toolID)
		local productKey = toolData.ProductKey
		NetClient:Request("Tool", "CheckExist", { ID = toolID }, function(isExist)
			if not isExist then
				IAPClient:Purchase(productKey, function(success)
					if success then
						NetClient:Request("Tool", "Equip", {ID = toolID }, function()
							EventManager:Dispatch(EventManager.Define.RefreshTool)
						end)
					end
				end)
			end
		end)
	end)
	
	building.RefreshFunc = function()
		NetClient:Request("Tool", "CheckExist", { ID = toolID }, function(result)
			local uiCost = Util:GetChildByName(buildingPart, "UICost")
			uiCost.Visible = not result
		end)
	end
	
	building:Refresh()

	task.spawn(function()
		BuildingToolIAP:ToolRotate(buildingPart)
	end)
end

function BuildingToolIAP:ToolRotate(buildingPart)
	local model = buildingPart:FindFirstChild("ToolMesh")
	BuildingToolIAP:WaitForModelWithBody(model)
	if model and model:IsDescendantOf(workspace) and model.PrimaryPart and model.PrimaryPart.Parent then
		UpdatorManager:RenderStepped(function(dt)
			local delta = CFrame.Angles(0, math.rad(RotationSpeed * dt), 0)
			model:SetPrimaryPartCFrame(model.PrimaryPart.CFrame * delta)
		end)
	end
end

function BuildingToolIAP:WaitForModelWithBody(model)
	if not model then return end
	local body
	repeat
		body = model:FindFirstChild("Body")
		task.wait()
	until body and body:IsA("BasePart")
	model.PrimaryPart = body
end

return BuildingToolIAP
