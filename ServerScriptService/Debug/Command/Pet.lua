local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local PetRequest = require(game.ServerScriptService.ScriptAlias.Pet)

local Pet = {}

Pet.Icon = "🐰"
Pet.Color = Color3.new(0.843137, 0.603922, 0.984314)

function Pet:Log(player, param)
	local module = PlayerPrefs:GetModule(player, "Pet")
	print(module)
end

function Pet:AddEquip1(player)
	PetRequest:AddEquipAdditional(player, { Value = 1 })
end

function Pet:AddPackage10(player)
	PetRequest:AddPackageAdditional(player, { Value = 10 })
end

function Pet:AddRand1(player)
	local petDataList = ConfigManager:GetDataList("Pet")
	local petData = Util:ListRandom(petDataList)
	local petID = petData.ID
	
	PetRequest:Add(player, {ID = petID})
end

function Pet:AddRand2(player)
	local petDataList = ConfigManager:GetDataList("Pet")
	local petData = Util:ListRandom(petDataList)
	local petID = petData.ID

	PetRequest:Add(player, {ID = petID, UpgradeLevel = 2})
end

function Pet:AddRand3(player)
	local petDataList = ConfigManager:GetDataList("Pet")
	local petData = Util:ListRandom(petDataList)
	local petID = petData.ID

	PetRequest:Add(player, {ID = petID, UpgradeLevel = 3})
end

function Pet:Clear(player)
	PlayerPrefs:SetModule(player, "Pet", {})
end

return Pet
