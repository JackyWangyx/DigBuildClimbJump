local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)

local SceneAreaManager = require(game.ServerScriptService.ScriptAlias.SceneAreaServerHandler)
local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)
local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local PlayerProperty = require(game.ServerScriptService.ScriptAlias.PlayerProperty)

local Scene = {}

--function LoadInfo(player)
--	local saveInfo = PlayerPrefs:GetModule(player, "System")
--	return saveInfo
--end

function Scene:GetAreaInfoList(player, param)
	local result = SceneAreaManager:CreateBroadcastInfoList()
	return result
end

return Scene