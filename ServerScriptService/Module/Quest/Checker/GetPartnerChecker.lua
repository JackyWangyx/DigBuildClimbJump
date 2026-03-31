local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)

local QuestChecker = require(game.ServerScriptService.ScriptAlias.QuestChecker)

local GetPartnerChecker = setmetatable({}, {__index = QuestChecker})
GetPartnerChecker.__index = GetPartnerChecker

function GetPartnerChecker.new(player, questType, questInfo)
	local self = setmetatable(QuestChecker.new(player, questType, questInfo), GetPartnerChecker) 
	return self
end

return GetPartnerChecker