local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local EventMananger = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local SoundMnaager = require(game.ReplicatedStorage.ScriptAlias.SoundManager)

local ClimbTowerGameManager = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameManager)

local Define = require(game.ReplicatedStorage.Define)

local ClimbTower = {}

function ClimbTower:UpdateGameInfo(player, param)
	ClimbTowerGameManager:OnUpdateGameInfo(param)
end

return ClimbTower
