local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)

local QuestChecker = require(game.ServerScriptService.ScriptAlias.QuestChecker)

local UnlockLevelChecker = setmetatable({}, {__index = QuestChecker})
UnlockLevelChecker.__index = UnlockLevelChecker

function UnlockLevelChecker.new(player, questType, questInfo)
	local self = setmetatable(QuestChecker.new(player, questType, questInfo), UnlockLevelChecker) 
	return self
end

return UnlockLevelChecker