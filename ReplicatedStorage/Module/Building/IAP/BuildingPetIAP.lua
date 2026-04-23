local ProximityArea = require(game.ReplicatedStorage.ScriptAlias.ProximityArea)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Building = require(game.ReplicatedStorage.ScriptAlias.Building)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local PetUtil = require(game.ReplicatedStorage.ScriptAlias.PetUtil)

local Define = require(game.ReplicatedStorage.Define)

local BuildingPetIAP = {}

function BuildingPetIAP:Handle(buildingPart, opts, petID)
	local building = Building.Trigger(buildingPart, opts, function() -- , Define.Message.BuyPetTip
		local petData = ConfigManager:GetData("Pet", petID)
		local productKey = petData.ProductKey
		NetClient:Request("Pet", "CheckPackage", function(result)
			if result then
				IAPClient:Purchase(productKey, function(result)
				end)
			else
				UIManager:ShowMessage(Define.Message.PackageFull)
			end
		end)
	end)
end

return BuildingPetIAP
