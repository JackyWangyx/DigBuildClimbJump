local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local Building = require(game.ReplicatedStorage.ScriptAlias.Building)
local SceneAreaManager = require(game.ReplicatedStorage.ScriptAlias.SceneAreaManager)

local ClimbTowerDefine = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerDefine)

local Define = require(game.ReplicatedStorage.Define)

local BuildingTowerUpdate = {}

function BuildingTowerUpdate:Init(buildingPart, opts)
	local lastOperateTime = 0
	local interval = ClimbTowerDefine.Game.TowerUpgradeDuration
	
	

	--local building = Building.ProximityOpenUI(buildingPart, opts, "Build", "TowerUpdate")
	local building = Building.Proximity(buildingPart, opts, "Build", function()
		local currentTime = os.time()	
		if currentTime - lastOperateTime < interval then
			return
		end
		
		lastOperateTime = currentTime
		NetClient:Request("ClimbTower", "UpgradeTower", function(result)
			if result.Success then
				--local areaInfo = SceneAreaManager.AreaInfoList[opts.AreaIndex]
				--local root = areaInfo.Area.Game.Tower.Root
				
				
				
			else
				
			end
		end)
	end)
end

return BuildingTowerUpdate
