local Building = require(game.ReplicatedStorage.ScriptAlias.Building)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local Define = require(game.ReplicatedStorage.Define)

local BuildingDonate = {}

function BuildingDonate:Init(buildingPart, opts)
	local uiDonate = Util:GetChildByName(buildingPart, "UIDonate")
	UIManager:InitPage(uiDonate)
end

return BuildingDonate
