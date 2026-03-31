local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)

local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)
local QuestChecker = require(game.ServerScriptService.ScriptAlias.QuestChecker)

local RebirthChecker = setmetatable({}, {__index = QuestChecker})
RebirthChecker.__index = RebirthChecker

function RebirthChecker.new(player, questType, questInfo)
	local self = setmetatable(QuestChecker.new(player, questType, questInfo), RebirthChecker) 
	return self
end

return RebirthChecker