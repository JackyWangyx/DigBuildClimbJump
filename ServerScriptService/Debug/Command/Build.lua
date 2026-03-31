local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)
local BuildRequest = require(game.ServerScriptService.ScriptAlias.Build)

local Build = {}

Build.Icon = "⚒️"
Build.Color = Color3.new(0, 0.666667, 1)

function Build:Log(player, param)
	local module = PlayerPrefs:GetModule(player, "Build")
	print(module)
end

function Build:AddRandPart(player)
	local partDataList = ConfigManager:GetDataList("BuildPart")
	local partData = Util:ListRandom(partDataList)
	BuildRequest:AddPart(player, { ID = partData.ID, Count = 1 })
end

function Build:GetPart(player)
	local partDataList = ConfigManager:GetDataList("BuildPart")
	for _, partData in ipairs(partDataList) do
		BuildRequest:AddPart(player, { ID = partData.ID, Count = 99 })
	end
end

function Build:Clear(player)
	PlayerPrefs:SetModule(player, "Build", {})
end

return Build
