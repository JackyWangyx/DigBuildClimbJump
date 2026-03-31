local ClimbTowerServerHandler =require(game.ServerScriptService.ScriptAlias.ClimbTowerServerHandler)
local ClimbTowerGameServerHandler = require(game.ServerScriptService.ScriptAlias.ClimbTowerGameServerHandler)

local Define = require(game.ReplicatedStorage.Define)

local ClimbTowerServer = {}

function ClimbTowerServer:Init()
	ClimbTowerServerHandler:Init()
	ClimbTowerGameServerHandler:Init()
end

return ClimbTowerServer
