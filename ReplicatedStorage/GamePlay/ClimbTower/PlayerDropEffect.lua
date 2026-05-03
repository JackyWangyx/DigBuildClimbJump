local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)

local PlayerDropEffect = {}

-- 三圈配置：
-- startRadiusRange：出生时离中心的距离
-- endRadiusRange：炸飞后离中心的最终距离
-- startSizeRange：出生尺寸
-- endSizeRange：炸飞到终点后的最大尺寸
-- heightRange：出生/炸飞高度，内圈低，外圈高
local RINGS_CONFIG = {
	{
		startRadiusRange = {min = 1.5, max = 2.0},
		endRadiusRange = {min = 4, max = 4.5},
		startSizeRange = {min = 0.4, max = 0.8},
		endSizeRange = {min = 1.2, max = 2.2},
		heightRange = {min = -0.4, max = -0.2},
		count = 8
	},
	{
		startRadiusRange = {min = 2.5, max = 3.5},
		endRadiusRange = {min = 6.5, max = 8.5},
		startSizeRange = {min = 0.8, max = 1.2},
		endSizeRange = {min = 2.4, max = 3.2},
		heightRange = {min = -0.2, max = 0},
		count = 12
	},
	{
		startRadiusRange = {min = 4.0, max = 5.0},
		endRadiusRange = {min = 13, max = 14},
		startSizeRange = {min = 1.0, max = 1.5},
		endSizeRange = {min = 4.0, max = 5.0},
		heightRange = {min = -0.1, max = 0},
		count = 16
	}
}

local HEIGHT_MULTIPLIER = 1.0

local EXPLODE_DURATION = 0.1 -- 从中心炸开的时间
local HOLD_DURATION = 1.0    -- 到最大范围后停留 N 秒
local FALL_DURATION = 0.5    -- 下落消失时间
local MOVE_DOWN_N = 12       -- 下沉距离

local ANGLE_RANDOM_DEGREES = 18

local function randomRange(range)
	return (math.random() * (range.max - range.min)) + range.min
end

local function spawnVisualEffect(centerPosition)
	for _, config in ipairs(RINGS_CONFIG) do
		for i = 1, config.count do
			local angle = ((i / config.count) * math.pi * 2)
				+ math.rad(math.random(-ANGLE_RANDOM_DEGREES, ANGLE_RANDOM_DEGREES))

			local direction = Vector3.new(
				math.cos(angle),
				0,
				math.sin(angle)
			)

			local startRadius = randomRange(config.startRadiusRange)
			local endRadius = randomRange(config.endRadiusRange)
			local height = randomRange(config.heightRange) * HEIGHT_MULTIPLIER

			local startSize = randomRange(config.startSizeRange)
			local endSize = randomRange(config.endSizeRange)

			local randomRot = CFrame.Angles(
				math.rad(math.random(0, 360)),
				math.rad(math.random(0, 360)),
				math.rad(math.random(0, 360))
			)

			local startPosition = centerPosition + direction * startRadius + Vector3.new(0, height * 0.3, 0)
			local endPosition = centerPosition + direction * endRadius + Vector3.new(0, height, 0)

			local part = Instance.new("Part")
			part.Name = "EffectParticle"
			--part.Material = Enum.Material.Slate
			part.Material = Enum.Material.Plastic

			part.TopSurface = Enum.SurfaceType.Studs
			part.BottomSurface = Enum.SurfaceType.Studs
			part.LeftSurface = Enum.SurfaceType.Studs
			part.RightSurface = Enum.SurfaceType.Studs
			part.FrontSurface = Enum.SurfaceType.Studs
			part.BackSurface = Enum.SurfaceType.Studs
			
			part.Color = Color3.fromRGB(99, 100, 113)
			
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Transparency = 0
			part.Size = Vector3.new(startSize, startSize, startSize)
			part.CFrame = CFrame.new(startPosition) * randomRot
			part.Parent = workspace

			local explodeTween = TweenService:Create(
				part,
				TweenInfo.new(
					EXPLODE_DURATION,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.Out
				),
				{
					CFrame = CFrame.new(endPosition) * randomRot,
					Size = Vector3.new(endSize, endSize, endSize)
				}
			)

			explodeTween.Completed:Once(function()
				if not part or not part.Parent then
					return
				end

				task.delay(HOLD_DURATION, function()
					if not part or not part.Parent then
						return
					end

					local fallTween = TweenService:Create(
						part,
						TweenInfo.new(
							FALL_DURATION,
							Enum.EasingStyle.Sine,
							Enum.EasingDirection.In
						),
						{
							CFrame = part.CFrame - Vector3.new(0, MOVE_DOWN_N, 0),
							Transparency = 1
						}
					)

					fallTween.Completed:Once(function()
						if part and part.Parent then
							part:Destroy()
						end
					end)

					fallTween:Play()
				end)
			end)

			explodeTween:Play()
		end
	end
end

function PlayerDropEffect:Play()
	local rootPart = PlayerManager:GetHumanoidRootPart(game.Players.LocalPlayer)
	if rootPart then
		local pos = rootPart.Position
		pos = Vector3.new(pos.X, 0, pos.Z)
		spawnVisualEffect(pos)
	end
end

return PlayerDropEffect
