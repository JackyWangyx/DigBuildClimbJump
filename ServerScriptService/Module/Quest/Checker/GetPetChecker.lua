local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)

local QuestChecker = require(game.ServerScriptService.ScriptAlias.QuestChecker)

local GetPetChecker = setmetatable({}, {__index = QuestChecker})
GetPetChecker.__index = GetPetChecker

function GetPetChecker.new(player, questType, questInfo)
	local self = setmetatable(QuestChecker.new(player, questType, questInfo), GetPetChecker) 
	return self
end

return GetPetChecker