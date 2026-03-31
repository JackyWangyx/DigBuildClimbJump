local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)

local GuideStep = require(game.ReplicatedStorage.ScriptAlias.GuideStep)

local GuideStepImpl = setmetatable({}, {__index = GuideStep })
GuideStepImpl.__index = GuideStepImpl

function GuideStepImpl.new(key, config, info)
	local self = setmetatable(GuideStep.new(key, config, info), GuideStepImpl) 
	return self
end

function GuideStepImpl:InitImpl()
	
end

local TriggerEvent = nil

function GuideStepImpl:EnableImpl()
	TriggerEvent = function(uiName)
		if uiName == "UIPetLoot" then
			self:Complete()
		end
	end

	EventManager:Listen(EventManager.Define.HideUI, TriggerEvent)
end

function GuideStepImpl:DisableImpl()
	EventManager:Remove(EventManager.Define.HideUI, TriggerEvent)
	TriggerEvent = nil
end

return GuideStepImpl