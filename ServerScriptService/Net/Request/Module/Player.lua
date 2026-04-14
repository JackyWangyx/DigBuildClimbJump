local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local PathManager = require(game.ReplicatedStorage.ScriptAlias.PathManager)
local RewardUtil = require(game.ReplicatedStorage.ScriptAlias.RewardUtil)

local PlayerProperty = require(game.ServerScriptService.ScriptAlias.PlayerProperty)
local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)
local PlayerStatus = require(game.ServerScriptService.ScriptAlias.PlayerStatus)
local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)

local AccountRequest = require(game.ServerScriptService.ScriptAlias.Account)

local Player = {}

function Player:CheckSaveLoaded(player)
	local result = PlayerPrefs:GetPlayerSaveInfoState(player)
	return result
end

-- Property
function Player:GetPower(player)
	local power = AccountRequest:GetPower(player)
	return power
end

-- Status
function Player:GetStatus(player)
	return PlayerStatus:GetStatus(player)
end

-- Record
function Player:GetRecord(player, param)
	local key = param.Key
	local value = PlayerRecord:GetValue(player, key)
	return value
end

-- Find Path
function Player:FindPathTo(player, param)
	PathManager:FindPathTo(player, param.TargetPosition)
end

-- Property
function Player:AddProperty1(player, param)
	local property = param.Property
	local value = param.Value
	local oldValue = PlayerProperty:GetPlayerPropertyValue1(player, property)
	local newValue = oldValue + value
	PlayerProperty:SetPlayerPropertyValue1(player, property, newValue)
end

function Player:GetGamePropertyValue(player, param)
	local property = param.Property
	local value = PlayerProperty:GetGamePropertyValue(player, property)
	return value
end

-- Animation
function Player:PlayAnimation(player, param)
	local animationAssetID = param.AnimationAssetID
	local loop = param.Loop
	local speed = param.speed
	PlayerManager:PlayAnimation(player, animationAssetID, loop, speed)
end

function Player:StopAnimation(player, param)
	local animationAssetID = param.AnimationAssetID
	PlayerManager:StopAnimation(player, animationAssetID)
end

-- Transform
function Player:EnablePhysic(player, param)
	PlayerManager:EnablePhysic(player)
	return true
end

function Player:DisablePhysic(player, param)
	PlayerManager:DisablePhysic(player)
	return true
end

function Player:SetPosition(player, param)
	local position = param.Position
	PlayerManager:SetPosition(player, position)
	return true
end

function Player:SetPositionRoad(player, param)
	local position = param.Position
	PlayerManager:SetPositionRoad(player, position)
	return true
end

function Player:SetForward(player, param)
	local forward = param.Forward
	PlayerManager:SetForward(player, forward)
	return true
end

function Player:SetRotation(player, param)
	local rotation = param.Rotation
	PlayerManager:SetRotation(player, rotation)
	return true
end

function Player:SetLookAt(player, param)
	local position = param.Position
	PlayerManager:SetLookAt(player, position)
	return true
end

return Player
