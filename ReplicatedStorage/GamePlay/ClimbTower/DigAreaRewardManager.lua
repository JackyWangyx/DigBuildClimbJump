local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local ResourcesManager = require(game.ReplicatedStorage.ScriptAlias.ResourcesManager)
local TriggerArea = require(game.ReplicatedStorage.ScriptAlias.TriggerArea)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local SoundManager = require(game.ReplicatedStorage.ScriptAlias.SoundManager)

local DigAreaRewardManager = {}

local DataList = nil
local BoxList = {}

function DigAreaRewardManager:Init()
	DataList = ConfigManager:GetDataList("DigAreaReward")
end

function DigAreaRewardManager:Reset()
	DigAreaRewardManager:Clear()
	local root = game.Workspace.DigAreaReward
	local layerList = root:GetChildren()
	for i = 1, #layerList do
		local layer = layerList[i]
		local pointList = layer:GetChildren()
		local point = Util:ListRandom(pointList, 1)
		local data = Util:ListRandomWeight(DataList, 1)
		
		local prefab = ResourcesManager:Load(data.Prefab)
		if prefab then
			local box = prefab:Clone()
			box.Parent = root
			box:PivotTo(point.CFrame)
			box.Name = "Box_" .. #BoxList .. "_" .. prefab.Name

			TriggerArea:Handle(box.Trigger, function()
				DigAreaRewardManager:GetReward(box, data)
			end, function()

			end, true)

			table.insert(BoxList, box)
		end	
	end
end

function DigAreaRewardManager:GetReward(box, data)
	NetClient:Request("ClimbTower", "GetDigAreaReward", { ID = data.ID },  function(result)
		if not box then return end
		if result.Success then
			SoundManager:PlaySFX(SoundManager.Define.OpenRewardBox)
			local fxPrefab = ResourcesManager:Load("Fx/Fx_GetWin")
			Util:SpawnFxEmit(fxPrefab, box.Trigger.Position, 10, 3)
						
			local rewardList = result.RewardList
			for _, data in ipairs(rewardList) do
				UIManager:ShowMessageWithIcon(data.Icon, "Got "..data.Description)
				task.wait()
			end
			
			task.wait()
			box:Destroy()		
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
