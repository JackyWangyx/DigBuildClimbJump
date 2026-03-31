local RunService = game:GetService("RunService")

local SceneManager = require(game.ReplicatedStorage.ScriptAlias.SceneManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local Define = require(game.ReplicatedStorage.Define)

local AnimalClientHandler = {}

local Player = nil
local PetCacheInfo = {}

function AnimalClientHandler:Init()
	Player = game.Players.LocalPlayer
end

function AnimalClientHandler:RefreshInfo(info)

end

function AnimalClientHandler:Update(deltaTime)

end



return AnimalClientHandler
