local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)

local QuestChecker = require(game.ServerScriptService.ScriptAlias.QuestChecker)

local GetPassPointChecker = setmetatable({}, {__index = QuestChecker})
GetPassPointChecker.__index = GetPassPointChecker

function GetPassPointChecker.new(player, questType, questInfo)
	local self = setmetatable(QuestChecker.new(player, questType, questInfo), GetPassPointChecker) 
	return self
end

return GetPassPointChecker