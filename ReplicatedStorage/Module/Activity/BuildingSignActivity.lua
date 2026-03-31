local ProximityAreaOpenUI = require(game.ReplicatedStorage.ScriptAlias.ProximityAreaOpenUI)
local TriggerAreaOpenUI = require(game.ReplicatedStorage.ScriptAlias.TriggerAreaOpenUI)
local NearTrigger = require(game.ReplicatedStorage.ScriptAlias.NearTrigger)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UTween = require(game.ReplicatedStorage.ScriptAlias.UTween)
local Building = require(game.ReplicatedStorage.ScriptAlias.Building)

local BuildingSignActivity = {}

function BuildingSignActivity:Handle(buildingPart, opts, activityKey)
	local building = Building.TriggerOpenUI(buildingPart, opts, "Open Activity Page", "UISignActivity", {
		ActivityKey = activityKey,
	})
end

return BuildingSignActivity
