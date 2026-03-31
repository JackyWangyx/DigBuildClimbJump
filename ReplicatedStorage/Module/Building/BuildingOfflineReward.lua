local ProximityArea = require(game.ReplicatedStorage.ScriptAlias.ProximityArea)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local Building = require(game.ReplicatedStorage.ScriptAlias.Building)

local Define = require(game.ReplicatedStorage.Define)

local BuildingOfflineReward = {}

local Info = nil

function BuildingOfflineReward:Init(buildingPart, opts)
	local function refreshFunc()
		BuildingOfflineReward:Refresh(buildingPart)
	end
	
	BuildingOfflineReward:RefreshInfo(function()
		refreshFunc()
		if Info.RewardCoin <= 0 then
			buildingPart:Destroy()
			return
		end
	end)
	
	local building = Building.Trigger(buildingPart, opts, function()
		if not Info then return end
		if Info.RewardCoin <= 0 then return end
		NetClient:Request("OfflineReward", "GetReward", function()
			buildingPart:Destroy()
		end)
	end)
end

function BuildingOfflineReward:RefreshInfo(onDone)
	NetClient:Request("OfflineReward", "GetInfo", function(info)
		Info = info
		if onDone then onDone() end
	end)
end

function BuildingOfflineReward:Refresh(buildingPart)
	UIInfo:SetInfo(buildingPart, Info)
end

return BuildingOfflineReward
