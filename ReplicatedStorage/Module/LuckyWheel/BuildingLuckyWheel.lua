local ProximityAreaOpenUI = require(game.ReplicatedStorage.ScriptAlias.ProximityAreaOpenUI)
local TriggerAreaOpenUI = require(game.ReplicatedStorage.ScriptAlias.TriggerAreaOpenUI)
local UTween = require(game.ReplicatedStorage.ScriptAlias.UTween)
local Building = require(game.ReplicatedStorage.ScriptAlias.Building)

local BuildingLuckyWheel = {}

function BuildingLuckyWheel:Init(buildingPart, opts)
	local building = Building.TriggerOpenUI(buildingPart, opts, "LuckyWheel")

	UTween:ModelRotation(buildingPart.Wheel, Vector3.new(0,90,0), Vector3.new(0,90,360), 5)
		:SetLoop(UTween.LoopType.Loop, 0)
end

return BuildingLuckyWheel
