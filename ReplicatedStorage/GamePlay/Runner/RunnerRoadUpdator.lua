local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local RunnerGameMnaager = require(game.ReplicatedStorage.ScriptAlias.RunnerGameManager)

local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local TriggerArea = require(game.ReplicatedStorage.ScriptAlias.TriggerArea)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local SceneManager = require(game.ReplicatedStorage.ScriptAlias.SceneManager)
local TaskManager = require(game.ReplicatedStorage.ScriptAlias.TaskManager)
local ObjectPool = require(game.ReplicatedStorage.ScriptAlias.ObjectPool)

local Define = require(game.ReplicatedStorage.Define)

local RunnerRoadUpdator = {}

SegmentPrefab = nil
SegmentLength = 2000 
SegmentHeight = -5
VisibleDistance = 20000
StartPosZ = 1100
local HalfVisibleCount = math.ceil(VisibleDistance / SegmentLength)

function RunnerRoadUpdator:Init()
	SegmentPrefab = Util:LoadPrefab("Road/"..SceneManager.CurrentLevelName.."/Road")	
	UpdatorManager:Heartbeat(function(deltaTime)
		RunnerRoadUpdator:Update(deltaTime)
	end)
end

Segments = {}
CurrentMinIndex = -1
CurrentMaxIndex = 99999

function RunnerRoadUpdator:Update(deltaTime)
	local player = game.Players.LocalPlayer
	
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	if not rootPart then return end
	
	local playerZ = rootPart.Position.Z
	local centerIndex = math.floor(math.abs(playerZ - StartPosZ) / SegmentLength)

	
	local targetMinIndex = centerIndex - HalfVisibleCount
	if targetMinIndex < 0 then
		targetMinIndex = 0
	end
	local targetMaxIndex = centerIndex + HalfVisibleCount
	if targetMaxIndex < 0 then
		targetMaxIndex = 0
	end

	-- 生成新段
	for i = targetMinIndex, targetMaxIndex do
		if not Segments[i] and SegmentPrefab ~= nil then
			local newSegment = ObjectPool:Spawn(SegmentPrefab)
			if newSegment then
				newSegment.Parent = RunnerGameMnaager.RoadRoot
				newSegment.Name = "Raod_"..i
				--Util:SetPosition(newSegment, Vector3.new(0, 0, i * SegmentLength))
				newSegment.CFrame = CFrame.new(0, SegmentHeight, -i * SegmentLength - StartPosZ)
				Segments[i] = newSegment
			end	
		end
	end

	-- 删除超出范围的段
	for i = CurrentMinIndex, CurrentMaxIndex do
		if i < targetMinIndex or i > targetMaxIndex then
			if Segments[i] then
				ObjectPool:DeSpawn(Segments[i])
				Segments[i] = nil
			end
		end
	end

	CurrentMinIndex = targetMinIndex
	CurrentMaxIndex = targetMaxIndex
end

return RunnerRoadUpdator
