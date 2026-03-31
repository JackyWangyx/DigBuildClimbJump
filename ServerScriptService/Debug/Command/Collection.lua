local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local AnimalRequest = require(game.ServerScriptService.ScriptAlias.Animal)

local Collection = {}

Collection.Icon = "📚"
Collection.Color = Color3.new(0.933333, 0.0588235, 0.321569)

function Collection:Log(player, param)
	local module = PlayerPrefs:GetModule(player, "Collection")
	print(module)
end

function Collection:Clear(player)
	PlayerPrefs:SetModule(player, "Collection", {})
end

return Collection
