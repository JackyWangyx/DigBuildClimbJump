local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local Building = require(game.ReplicatedStorage.ScriptAlias.Building)

local ClimbTowerGameManager = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameManager)

local Define = require(game.ReplicatedStorage.Define)

local BuildingGetWins = {}

function BuildingGetWins:Init(buildingPart, opts)
	opts.Mode = Building.Mode.Global
	local building = Building.Trigger(buildingPart, opts, function()
		ClimbTowerGameManager:GetWins(opts.AreaIndex)
	end)
end

return BuildingGetWins
