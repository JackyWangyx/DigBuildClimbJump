local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)

local QuestChecker = require(game.ServerScriptService.ScriptAlias.QuestChecker)

local CompleteGameChecker = setmetatable({}, {__index = QuestChecker})
CompleteGameChecker.__index = CompleteGameChecker

function CompleteGameChecker.new(player, questType, questInfo)
	local self = setmetatable(QuestChecker.new(player, questType, questInfo), CompleteGameChecker) 
	return self
end

return CompleteGameChecker