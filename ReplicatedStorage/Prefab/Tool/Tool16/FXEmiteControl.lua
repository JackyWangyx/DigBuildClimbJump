-- 放在 Car/LocalScript
local Players = game:GetService("Players")

local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local ClimbTowerGameLoop = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerGameLoop)
local ClimbTowerDefine = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerDefine)

local RATE_MOVING = 80-- 移动时发射速率
local POSITION_THRESHOLD = 0.01 -- 每帧位置变化阈值（单位：studs，根据帧率调整以模拟速度阈值）

local car = script.Parent
local handle = car:WaitForChild("Handle")
local EffectIdleFolder = handle:FindFirstChild("Effect_Idle")
local EffectGameFolder = handle:FindFirstChild("Effect_Game")

local character = car:FindFirstAncestorOfClass("Model")
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
local hrp = character and character:FindFirstChild("HumanoidRootPart")
if not (humanoid and hrp) then return end

-- 克隆本地发射器（保留所有参数，只关掉开关）
local AllEmitters = {}
local IdleEmitters = {}
local GameEmitters = {}

if EffectIdleFolder then
	for _, att in ipairs(EffectIdleFolder:GetChildren()) do
		if att:IsA("Attachment") then
			for _, pe in ipairs(att:GetChildren()) do
				if pe:IsA("ParticleEmitter") then
					-- 模板永远关掉，别人不会看到
					pe.Enabled = false
					pe.Rate = 0
					-- 本地副本
					local clone = pe:Clone()
					clone.Name = "LocalOnlyEmitter"
					clone.Enabled = false
					clone.Rate = 0
					clone.Parent = att
					table.insert(AllEmitters, clone)
					table.insert(IdleEmitters, clone)
				end
			end
		end
	end
end

if EffectGameFolder then
	for _, att in ipairs(EffectGameFolder:GetChildren()) do
		if att:IsA("Attachment") then
			for _, pe in ipairs(att:GetChildren()) do
				if pe:IsA("ParticleEmitter") then
					-- 模板永远关掉，别人不会看到
					pe.Enabled = false
					pe.Rate = 0
					-- 本地副本
					local clone = pe:Clone()
					clone.Name = "LocalOnlyEmitter"
					clone.Enabled = false
					clone.Rate = 0
					clone.Parent = att
					table.insert(AllEmitters, clone)
					table.insert(GameEmitters, clone)
				end
			end
		end
	end
end

local function setEmit(on)
	for _, e in ipairs(AllEmitters) do
		if on then
			e.Enabled = true
			e.Rate = RATE_MOVING
		else
			e.Rate = 0
			e.Enabled = false
		end
	end
end

local function setGameEmit(on)
	for _, e in ipairs(GameEmitters) do
		if on then
			e.Enabled = true
			e.Rate = RATE_MOVING
		else
			e.Rate = 0
			e.Enabled = false
		end
	end
end

local function setIdleEmit(on)
	for _, e in ipairs(IdleEmitters) do
		if on then
			e.Enabled = true
			e.Rate = RATE_MOVING
		else
			e.Rate = 0
			e.Enabled = false
		end
	end
end

-- 初始化上一次位置
local lastPosition = hrp.Position

-- 按帧检测位置变化
UpdatorManager:RenderStepped(function()
	if not hrp then return end

	local currentPosition = hrp.Position
	local deltaPosition = (currentPosition - lastPosition).Magnitude

	if deltaPosition >= POSITION_THRESHOLD then
		local currentGamePhase = ClimbTowerGameLoop.GamePhase
		if currentGamePhase == ClimbTowerDefine.GamePhase.Idle or currentGamePhase == ClimbTowerDefine.GamePhase.ArriveEnd then
			setIdleEmit(true)
		else
			setGameEmit(true)
		end
	else
		setEmit(false)
	end

	lastPosition = currentPosition
end)