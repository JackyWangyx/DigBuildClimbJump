local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)

local QuestChecker = require(game.ServerScriptService.ScriptAlias.QuestChecker)

local ArriveEndChecker = setmetatable({}, {__index = QuestChecker})
ArriveEndChecker.__index = ArriveEndChecker

function ArriveEndChecker.new(player, questType, questInfo)
	local self = setmetatable(QuestChecker.new(player, questType, questInfo), ArriveEndChecker) 
	return self
end

return ArriveEndChecker