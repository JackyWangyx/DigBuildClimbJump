local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local Record = {}

Record.Icon = "📝"
Record.Color = Color3.new(0.917647, 0.921569, 0.941176)

function Record:Log(player, param)
	local module = PlayerPrefs:GetModule(player, "PlayerRecord")
	print(module)
end

function Record:Clear(player)
	PlayerPrefs:SetModule(player, "PlayerRecord", {})
end

return Record