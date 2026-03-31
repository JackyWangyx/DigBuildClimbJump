local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)

local QuestChecker = require(game.ServerScriptService.ScriptAlias.QuestChecker)

local GetToolChecker = setmetatable({}, {__index = QuestChecker})
GetToolChecker.__index = GetToolChecker

function GetToolChecker.new(player, questType, questInfo)
	local self = setmetatable(QuestChecker.new(player, questType, questInfo), GetToolChecker) 
	return self
end

return GetToolChecker