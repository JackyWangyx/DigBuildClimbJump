local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local Building = require(game.ReplicatedStorage.ScriptAlias.Building)

local ClimbTowerGameManager = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameManager)

local Define = require(game.ReplicatedStorage.Define)

local BuildingDigArea = {}

function BuildingDigArea:Init(buildingPart, opts)
	opts.Mode = Building.Mode.Global
	local building = Building.Trigger(buildingPart, opts, function()
		ClimbTowerGameManager:EnterDig()
	end, function()
		ClimbTowerGameManager:ExitDig()
	end)
end

return BuildingDigArea
