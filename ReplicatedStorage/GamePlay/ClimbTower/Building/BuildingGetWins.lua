local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local Building = require(game.ReplicatedStorage.ScriptAlias.Building)
local SoundManager = require(game.ReplicatedStorage.ScriptAlias.SoundManager)
local ResourcesManager = require(game.ReplicatedStorage.ScriptAlias.ResourcesManager)
local SceneAreaManager = require(game.ReplicatedStorage.ScriptAlias.SceneAreaManager)

local ClimbTowerGameManager = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameManager)
local ClimbTowerDefine = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerDefine)

local Define = require(game.ReplicatedStorage.Define)

local BuildingGetWins = {}

function BuildingGetWins:Init(buildingPart, opts)
	opts.Mode = Building.Mode.Global
	local building = Building.Trigger(buildingPart, opts, function()
		ClimbTowerGameManager:GetWins(opts.AreaIndex)
		
		SoundManager:PlaySFX(SoundManager.Define.OpenRewardBox)
		local fxPrefab = ResourcesManager:Load("Fx/Fx_GetWin")
		Util:SpawnFxEmit(fxPrefab, buildingPart.Trigger.Position, 10, 3)
	end)
	
	if opts.AreaIndex == SceneAreaManager:GetCurrentAreaIndex() then
		EventManager:Listen(ClimbTowerDefine.Event.Enter, function()
			Util:ActiveObject(buildingPart)
		end)

		EventManager:Listen(ClimbTowerDefine.Event.GetWins, function()
			Util:DeActiveObject(buildingPart)
		end)
	end
end

return BuildingGetWins
