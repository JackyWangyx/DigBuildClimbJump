local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local EventMananger = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local TrainingMachine = require(game.ReplicatedStorage.ScriptAlias.TrainingMachine)

local Training = {}

function Training:OnTraining(player, param)
	TrainingMachine:OnTraining(player, param)
end

return Training
