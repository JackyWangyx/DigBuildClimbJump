local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local Equipment = {}

Equipment.Icon = "🛠️"
Equipment.Color = Color3.new(0.803922, 0.796078, 0.941176)

function Equipment:Log(player, param)
	local module = PlayerPrefs:GetModule(player, "Equipment")
	print(module)
end

function Equipment:Clear(player)
	PlayerPrefs:SetModule(player, "Equipment", {})
end

return Equipment
