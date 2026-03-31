local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)

local QuestChecker = require(game.ServerScriptService.ScriptAlias.QuestChecker)

local GetAnimalChecker = setmetatable({}, {__index = QuestChecker})
GetAnimalChecker.__index = GetAnimalChecker

function GetAnimalChecker.new(player, questType, questInfo)
	local self = setmetatable(QuestChecker.new(player, questType, questInfo), GetAnimalChecker) 
	return self
end

return GetAnimalChecker