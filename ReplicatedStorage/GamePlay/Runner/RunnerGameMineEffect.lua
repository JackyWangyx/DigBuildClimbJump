
local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)

local SceneManager = require(game.ReplicatedStorage.ScriptAlias.SceneManager)
local ObjectPool = require(game.ReplicatedStorage.ScriptAlias.ObjectPool)

local RunnerGameMineEffect = {}


local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

-- 状态与配置
RunnerGameMineEffect.IsGaming = false
RunnerGameMineEffect.EffectPrefab = nil
RunnerGameMineEffect.ToolOffset = Vector3.zero
RunnerGameMineEffect.CurrentSpeed = 0
RunnerGameMineEffect.MaxFlyingBlocks = 200

-- 内部缓存
local flyingBlocks = {}
local headWidth = 10
local timePassed = 0
local flyingTime = 1.5
local gravity = -60

-- 单例更新绑定
function RunnerGameMineEffect:Init()
	if self._connected then return end
	self._connected = UpdatorManager:RenderStepped(function(dt)
		self:Update(dt)
	end)
end

-- 游戏状态切换
function RunnerGameMineEffect:OnStart()
	self.IsGaming = true
	timePassed = 0
end

function RunnerGameMineEffect:OnFinish()
	self.IsGaming = false
	self:ClearBlocks()
end

RunnerGameMineEffect.OnLeave = RunnerGameMineEffect.OnFinish

-- 主更新函数
function RunnerGameMineEffect:Update(dt)
	timePassed += dt

	-- 发射逻辑
	local cps = self:GetCountPerSecondBySpeed(self.CurrentSpeed)
	local emitInterval = cps > 0 and (1 / cps) or math.huge
	while self.IsGaming and timePassed >= emitInterval do
		timePassed -= emitInterval
		self:CreateFlyingBlock()
	end

	-- 更新飞块
	if not self.IsGaming then
		self:ClearBlocks()
		return
	end

	local now = os.clock()
	local basePart = self:GetBasePart()
	if not basePart then return end

	for i = #flyingBlocks, 1, -1 do
		local info = flyingBlocks[i]
		local t = now - info.born

		if t > flyingTime then
			ObjectPool:DeSpawn(info.block)
			table.remove(flyingBlocks, i)
		else
			local localOffset = Vector3.new(info.offsetX, info.offsetY, 0) + self.ToolOffset
			local localDisplacement = info.v0 * t + Vector3.new(0, 0.5 * gravity * t * t, 0)
			local localPos = localOffset + localDisplacement

			local worldPos = basePart.CFrame:PointToWorldSpace(localPos)
			local rot = info.rotSpeed * t
			info.block.CFrame = CFrame.new(worldPos) * CFrame.Angles(rot.X, rot.Y, rot.Z)
		end
	end
end

-- 清理所有飞块
function RunnerGameMineEffect:ClearBlocks()
	for i = #flyingBlocks, 1, -1 do
		ObjectPool:DeSpawn(flyingBlocks[i].block)
		table.remove(flyingBlocks, i)
	end
end

-- 获取 HumanoidRootPart
function RunnerGameMineEffect:GetBasePart()
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	return character:FindFirstChild("HumanoidRootPart")
end

-- 创建飞块
function RunnerGameMineEffect:CreateFlyingBlock()
	if #flyingBlocks >= self.MaxFlyingBlocks then return end

	local offsetX = (math.random() - 0.5) * headWidth
	local offsetY = 2
	local size = math.random(15, 25) / 10

	-- 根据玩家速度计算飞块初速
	local minPlayerSpeed, maxPlayerSpeed = 10, 2500
	local minBlockSpeed, maxBlockSpeed = 35, 100
	local exponent = 0.75

	local spdExp = self.CurrentSpeed ^ exponent
	local minExp = minPlayerSpeed ^ exponent
	local maxExp = maxPlayerSpeed ^ exponent
	local percent = math.clamp((spdExp - minExp) / (maxExp - minExp), 0, 1)

	local blockSpeed = minBlockSpeed + (maxBlockSpeed - minBlockSpeed) * percent
	local speed = blockSpeed + math.random() * 15

	-- 扩散角度
	local spread = math.rad(math.random(-30, 30))
	local upAngle = math.rad(math.random(40, 50))
	local ySpeed = speed * math.sin(upAngle)
	local zSpeed = speed * math.cos(upAngle)
	local localV0 = Vector3.new(math.sin(spread) * speed * 0.5, ySpeed, zSpeed)

	-- 随机旋转速度
	local rotSpeed = Vector3.new(
		math.rad(math.random(-180, 180)),
		math.rad(math.random(-180, 180)),
		math.rad(math.random(-180, 180))
	)

	if self.EffectPrefab then
		local block = ObjectPool:Spawn(self.EffectPrefab)
		block.Size = Vector3.new(size, size, size)
		block.Anchored = true
		block.CanCollide = false
		block.Parent = SceneManager.LevelRoot

		flyingBlocks[#flyingBlocks+1] = {
			block    = block,
			offsetX  = offsetX,
			offsetY  = offsetY,
			born     = os.clock(),
			v0       = localV0,
			rotSpeed = rotSpeed,
		}
	end
end

-- 根据速度计算每秒发射数量
function RunnerGameMineEffect:GetCountPerSecondBySpeed(speed)
	local minSpeed, maxSpeed = 10, 2500
	local minCount, maxCount = 20,200
	local exponent = 0.87

	local spdExp = speed ^ exponent
	local base = minSpeed ^ exponent
	local top = maxSpeed ^ exponent
	local percent = math.clamp((spdExp - base) / (top - base), 0, 1)

	local count = math.floor(minCount + (maxCount - minCount) * percent)
	local remain = self.MaxFlyingBlocks - #flyingBlocks
	if remain <= 0 then return 0 end
	return math.min(count, remain)
end

return RunnerGameMineEffect
