local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)

local QuestChecker = require(game.ServerScriptService.ScriptAlias.QuestChecker)

local GetWinsChecker = setmetatable({}, {__index = QuestChecker})
GetWinsChecker.__index = GetWinsChecker

function GetWinsChecker.new(player, questType, questInfo)
	local self = setmetatable(QuestChecker.new(player, questType, questInfo), GetWinsChecker) 
	return self
end

return GetWinsChecker