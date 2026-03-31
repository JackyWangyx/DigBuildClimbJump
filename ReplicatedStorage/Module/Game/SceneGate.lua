local RunService = game:GetService("RunService")

local TriggerArea = require(game.ReplicatedStorage.ScriptAlias.TriggerArea)
local ProximityArea = require(game.ReplicatedStorage.ScriptAlias.ProximityArea)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local Building = require(game.ReplicatedStorage.ScriptAlias.Building)

local Define = require(game.ReplicatedStorage.Define)

local SceneGate = {}

local IsWorking = false

function SceneGate:Handle(buildingPart, opts, index)
	local building = Building.Trigger(buildingPart, opts, function()
		local data = ConfigManager:GetData("Level", index)
		if IsWorking then 
			UIManager:ShowMessage(Define.Message.Teleporting)
			return 
		end

		IsWorking = true
		NetClient:Request("Level", "CheckLevel", { ID = index }, function(unlock)
			if unlock then
				if RunService:IsStudio() then
					UIManager:ShowMessage("Cannot transfer in Studio")
					return
				end

				NetClient:Request("Game", "Teleport", { PlaceID = data.PlaceID }, function(result)
					if not result.Success then
						UIManager:ShowMessage(result.Message)
					end

					IsWorking = false
				end)
			else
				UIManager:ShowMessage(Define.Message.EnterLevelFail)
				IsWorking = false
			end
		end)
	end)
	
	building.RefreshFunc = function()
		local uiFrame = Util:GetChildByName(buildingPart, "UIFrame")
		local data = ConfigManager:GetData("Level", index)
		UIInfo:SetInfo(uiFrame, data)
	end
	
	building:Refresh()
end

return SceneGate
