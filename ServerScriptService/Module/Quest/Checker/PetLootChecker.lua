local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)

local QuestChecker = require(game.ServerScriptService.ScriptAlias.QuestChecker)

local PetLootChecker = setmetatable({}, {__index = QuestChecker})
PetLootChecker.__index = PetLootChecker

function PetLootChecker.new(player, questType, questInfo)
	local self = setmetatable(QuestChecker.new(player, questType, questInfo), PetLootChecker) 
	return self
end

return PetLootChecker