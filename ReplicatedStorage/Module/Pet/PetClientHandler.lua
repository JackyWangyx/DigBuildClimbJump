local RunService = game:GetService("RunService")

local SceneManager = require(game.ReplicatedStorage.ScriptAlias.SceneManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local Define = require(game.ReplicatedStorage.Define)

local PetClientHandler = {}

local Player = nil
local PetCacheInfo = {}

function PetClientHandler:Init()
	Player = game.Players.LocalPlayer
end

function PetClientHandler:RefreshInfo(info)
	PetCacheInfo = {}
	for _, petRenderInfo in ipairs(info) do
		local pet = SceneManager.LevelRoot.Game.Pet:FindFirstChild(petRenderInfo.Name)
		local pos = petRenderInfo.Position
		local petInfo = {
			Pet = pet,
			Position = pos,
		}
		
		table.insert(PetCacheInfo, petInfo)
	end
end

function PetClientHandler:Update(deltaTime)
	if not Player.Character or not Player.Character.PrimaryPart then
		return
	end

	local playerRoot = Player.Character.PrimaryPart
	for _, petInfo in ipairs(PetCacheInfo) do
		local pet = petInfo.Pet
		if pet and pet.PrimaryPart then
			local playerCFrame = playerRoot.CFrame
			local targetWorldPos = playerCFrame:PointToWorldSpace(petInfo.Position)
			local currentPos = pet.PrimaryPart.Position
			local newPos

			if CurrentPlayerStatus == Define.PlayerStatus.Gaming then
				-- 🚀 比赛状态：直接固定在偏移位置
				newPos = targetWorldPos
			else
				-- 🐢 正常状态：插值跟随
				local speed = 60
				local offset = targetWorldPos - currentPos
				local distance = offset.Magnitude
				if distance > 0.05 then
					local moveDelta = math.min(distance, speed * deltaTime)
					newPos = currentPos + offset.Unit * moveDelta
				else
					newPos = currentPos
				end
			end

			-- 始终朝向玩家
			local lookTarget = playerRoot.Position
			local targetCFrame = CFrame.new(newPos, lookTarget)

			-- 平滑旋转（比赛中也用，避免瞬间抖动）
			local currentCFrame = pet.PrimaryPart.CFrame
			local lerpAlpha = (CurrentPlayerStatus == Define.PlayerStatus.Gaming) and 0.6 or 0.25
			local finalCFrame = currentCFrame:Lerp(targetCFrame, lerpAlpha)

			pet:SetPrimaryPartCFrame(finalCFrame)
		end
	end
end



return PetClientHandler
