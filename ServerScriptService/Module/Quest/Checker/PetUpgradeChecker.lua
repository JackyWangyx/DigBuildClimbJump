local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)

local QuestChecker = require(game.ServerScriptService.ScriptAlias.QuestChecker)

local PetUpgradeChecker = setmetatable({}, {__index = QuestChecker})
PetUpgradeChecker.__index = PetUpgradeChecker

function PetUpgradeChecker.new(player, questType, questInfo)
	local self = setmetatable(QuestChecker.new(player, questType, questInfo), PetUpgradeChecker) 
	return self
end

return PetUpgradeChecker