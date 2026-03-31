local ProximityAreaOpenUI = require(game.ReplicatedStorage.ScriptAlias.ProximityAreaOpenUI)
local TriggerAreaOpenUI = require(game.ReplicatedStorage.ScriptAlias.TriggerAreaOpenUI)
local NearTrigger = require(game.ReplicatedStorage.ScriptAlias.NearTrigger)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UTween = require(game.ReplicatedStorage.ScriptAlias.UTween)
local Building = require(game.ReplicatedStorage.ScriptAlias.Building)

local BuildingPetLoot = {}

function BuildingPetLoot:Handle(buildingPart, opts, lootKey, eggPrefab)
	local building = Building.TriggerOpenUI(buildingPart, opts, "UIPetLoot", {
		LootKey = lootKey,
		EggPrefab = eggPrefab,
	})
	
	local egg = Util:GetChildByNameFuzzy(buildingPart, "Egg")
	if egg then
		local tweenRotate = UTween:ModelRotation(egg, Vector3.new(0,0,0), Vector3.new(0, 360, 0), 10)
			:SetLoop(UTween.LoopType.Loop, 0)
		local eggPos = Util:GetPosition(egg)
		NearTrigger:Register(building.TriggerPart, 15, 2, function()
			UTween:ModelPosition(egg, eggPos, eggPos + Vector3.new(0, 2.5, 0), 0.5)
				:SetEase(UTween.EaseType.Parabola)
			
			local rotation = Util:GetRotation(egg)
			local y = rotation.Y
			tweenRotate:Pause()
			UTween:ModelRotation(egg, Vector3.new(0,y,0), Vector3.new(0, y, 25), 0.75)
				:SetEase(UTween.EaseType.Shake, 4)
				:SetOnComplete(function()
					tweenRotate:Play()
				end)
		end)	
	end
end

return BuildingPetLoot
