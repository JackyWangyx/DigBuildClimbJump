local ProximityArea = require(game.ReplicatedStorage.ScriptAlias.ProximityArea)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local Building = require(game.ReplicatedStorage.ScriptAlias.Building)

local Define = require(game.ReplicatedStorage.Define)

local BuildingAnimalIAP = {}

function BuildingAnimalIAP:Handle(buildingPart, opts, animalID)
	local building = Building.Proximity(buildingPart, opts, Define.Message.BuyAnimalTip, function()
		local animalData = ConfigManager:GetData("Animal", animalID)
		local productKey = animalData.ProductKey
		NetClient:Request("Animal", "CheckPackage", function(result)
			if result then
				IAPClient:Purchase(productKey, function(result)
					--BuildingAnimalIAP:Refresh(buildingPart, triggerPart, animalID)
				end)
			else
				UIManager:ShowMessage(Define.Message.PackageFull)
			end
		end)

	end)
end

return BuildingAnimalIAP
