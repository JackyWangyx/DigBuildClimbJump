local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local QuestDefine = require(game.ReplicatedStorage.ScriptAlias.QuestDefine)
local SceneAreaManager = require(game.ReplicatedStorage.ScriptAlias.SceneAreaManager)

local GuideStep = require(game.ReplicatedStorage.ScriptAlias.GuideStep)

local GuideStepImpl = setmetatable({}, {__index = GuideStep })
GuideStepImpl.__index = GuideStepImpl

function GuideStepImpl.new(key, config, info)
	local self = setmetatable(GuideStep.new(key, config, info), GuideStepImpl) 
	return self
end

function GuideStepImpl:InitImpl()
	
end

function GuideStepImpl:GetCustomTargetPos()
	local areaInfo = SceneAreaManager.AreaInfoList[SceneAreaManager.CurrentAreaIndex]
	local towerPos = areaInfo.Area.Game.TowerPos
	return towerPos.Position
end

return GuideStepImpl