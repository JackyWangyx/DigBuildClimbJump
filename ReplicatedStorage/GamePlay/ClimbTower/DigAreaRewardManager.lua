local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local ResourcesManager = require(game.ReplicatedStorage.ScriptAlias.ResourcesManager)
local TriggerArea = require(game.ReplicatedStorage.ScriptAlias.TriggerArea)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local SoundManager = require(game.ReplicatedStorage.ScriptAlias.SoundManager)
local HighlightUtil = require(game.ReplicatedStorage.ScriptAlias.HighlightUtil)

local DigAreaRewardManager = {}

local DataList = nil
local BoxList = {}

function DigAreaRewardManager:Init()
	DataList = ConfigManager:GetDataList("DigAreaReward")
end

function DigAreaRewardManager:Reset()
	DigAreaRewardManager:Clear()
	
	local root = game.Workspace:FindFirstChild("DigAreaReward")
	if root then
		local layerList = root:GetChildren()
		for layerIndex = 1, #layerList do
			local layer = layerList[layerIndex]
			local pointList = layer:GetChildren()
			local count = math.random(3, 4)
			local points = Util:ListRandom(pointList, count)
			local datas = Util:ListRandomWeight(DataList, count)

			for index, data in ipairs(datas) do
				if index > #points then break end
				
				local prefab = ResourcesManager:Load(data.Prefab)
				if prefab then
					local point = points[index]
					local box = prefab:Clone()
					box.Parent = root
					box:PivotTo(point.CFrame)
					box.Name = "Box_" .. #BoxList .. "_" .. prefab.Name

					HighlightUtil:HandleLOD(box)
					
					TriggerArea:Handle(box.Trigger, function()
						DigAreaRewardManager:GetReward(box, data)
					end, function()

					end, true)

					table.insert(BoxList, box)
				end	
			end
		end
	else
		warn("DigAreaReward not found")
	end
end

function DigAreaRewardManager:GetReward(box, data)
	if not box then return end
	
	local pos = box.Trigger.Position
	box:Destroy()	
	
	NetClient:Request("ClimbTower", "GetDigAreaReward", { ID = data.ID },  function(result)
		if result.Success then
			SoundManager:PlaySFX(SoundManager.Define.OpenRewardBox)
			local fxPrefab = ResourcesManager:Load("Fx/Fx_GetWin")
			Util:SpawnFxEmit(fxPrefab, pos, 10, 3)		
			local rewardList = result.RewardList
			for _, data in ipairs(rewardList) do
				UIManager:ShowMessageWithIcon(data.Icon, "Got "..data.Description)
				task.wait()
			end	
		else
			UIManager:ShowMessage(result.Message)
		end
	end)
end

function DigAreaRewardManager:Clear()
	for _, box in ipairs(BoxList) do
		box:Destroy()
	end
	
	BoxList = {}
end

return DigAreaRewardManager
