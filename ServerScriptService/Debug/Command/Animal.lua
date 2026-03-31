local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local AnimalRequest = require(game.ServerScriptService.ScriptAlias.Animal)

local Animal = {}

Animal.Icon = "🐶"
Animal.Color = Color3.new(0.984314, 0.643137, 0.792157)

function Animal:Log(player, param)
	local module = PlayerPrefs:GetModule(player, "Animal")
	print(module)
end

function Animal:AddEquip1(player)
	AnimalRequest:AddEquipAdditional(player, { Value = 1 })
end

function Animal:AddPackage10(player)
	AnimalRequest:AddPackageAdditional(player, { Value = 10 })
end

function Animal:AddRand1(player)
	local animalDataList = ConfigManager:GetDataList("Animal")
	local animalData = Util:ListRandom(animalDataList)
	local animalID = animalData.ID
	
	AnimalRequest:Add(player, {ID = animalID})
end

function Animal:AddRand2(player)
	local animalDataList = ConfigManager:GetDataList("Animal")
	local animalData = Util:ListRandom(animalDataList)
	local animalID = animalData.ID

	AnimalRequest:Add(player, {ID = animalID, UpgradeLevel = 2})
end

function Animal:AddRand3(player)
	local animalDataList = ConfigManager:GetDataList("Animal")
	local animalData = Util:ListRandom(animalDataList)
	local animalID = animalData.ID

	AnimalRequest:Add(player, {ID = animalID, UpgradeLevel = 3})
end

function Animal:Clear(player)
	PlayerPrefs:SetModule(player, "Animal", {})
end

return Animal
