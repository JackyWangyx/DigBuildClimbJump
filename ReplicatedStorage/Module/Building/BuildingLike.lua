local ProximityAreaOpenUI = require(game.ReplicatedStorage.ScriptAlias.ProximityAreaOpenUI)
local TriggerAreaOpenUI = require(game.ReplicatedStorage.ScriptAlias.TriggerAreaOpenUI)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local Building = require(game.ReplicatedStorage.ScriptAlias.Building)

local Define = require(game.ReplicatedStorage.Define)

local BuildingLike = {}

function BuildingLike:Init(buildingPart, opts)
	task.defer(function()
		local enable = BuildingLike:Refresh(buildingPart)
		if not enable then
			local building = Building.TriggerOpenUI(buildingPart, opts, "Like")
			EventManager:Listen(EventManager.Define.RefreshOfficalGroup, function()
				BuildingLike:Refresh(buildingPart)
			end)
		end	
	end)
end

function BuildingLike:Refresh(buildingPart)
	local buyCount = NetClient:RequestWait("IAP", "GetPackageCount", { ID = Define.Game.LikePackageID })
	if buyCount > 0 then
		buildingPart:Destroy()
		return true
	else
		return false
	end
end

return BuildingLike
