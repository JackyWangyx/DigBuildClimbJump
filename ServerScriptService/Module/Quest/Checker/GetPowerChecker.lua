local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)

local QuestChecker = require(game.ServerScriptService.ScriptAlias.QuestChecker)

local GetPowerChecker = setmetatable({}, {__index = QuestChecker})
GetPowerChecker.__index = GetPowerChecker

function GetPowerChecker.new(player, questType, questInfo)
	local self = setmetatable(QuestChecker.new(player, questType, questInfo), GetPowerChecker) 
	return self
end

return GetPowerChecker