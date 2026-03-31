local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)

local QuestChecker = require(game.ServerScriptService.ScriptAlias.QuestChecker)

local GetCoinChecker = setmetatable({}, {__index = QuestChecker})
GetCoinChecker.__index = GetCoinChecker

function GetCoinChecker.new(player, questType, questInfo)
	local self = setmetatable(QuestChecker.new(player, questType, questInfo), GetCoinChecker) 
	return self
end

return GetCoinChecker