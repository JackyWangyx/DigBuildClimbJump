local TweenService = game:GetService("TweenService")

local TweenUtil = require(game.ReplicatedStorage.ScriptAlias.TweenUtil)
local TweenServiceManager = require(game.ReplicatedStorage.ScriptAlias.TweenServiceManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local ClickGameDefine = require(script.Parent.ClickGameDefine)

local ClickGameEffect = {}

-- Effect

function ClickGameEffect:EffectRandMove(item)
	local parent = item.Parent
	local part = item.Part
	local duration = item.Duration
	local startPos = part.Position
	local targetPos = ClickGameEffect:GetRandomTargetPos(parent
		, startPos
		, ClickGameDefine.Game.RandMoveDistanceMin
		, ClickGameDefine.Game.RandMoveDistanceMax
		, ClickGameDefine.Game.ContainerWidth
		, ClickGameDefine.Game.ContainerHeight)
	
	ClickGameEffect:MoveToRandomPoint(part, startPos, targetPos, duration)
end

function ClickGameEffect:EffectLifeTimeScale(item)
	local part = item.Part.MainFrame
	local duration = item.Duration
	TweenServiceManager.New(part)
		:From(function()
			part.Size = UDim2.new(1, 0, 1, 0)
		end)
		:To({
			Size = UDim2.new(0, 0, 0, 0),
		})
		:SetDuration(duration)
		:SetEase(Enum.EasingStyle.Back, Enum.EasingDirection.In)
		:Play()
	
	local background = Util:GetChildByName(part, "Image_Background")
	if background then
		TweenServiceManager.New(background)
			:From(function()
				background.Rotation = 0
			end)
			:To({
				Rotation = 360
			})
			:SetDuration(duration)
			:SetEase(Enum.EasingStyle.Linear, Enum.EasingDirection.In)
			:Play()
	end
end

-- Move Effect

function ClickGameEffect:GetRandomPos(container, percentWidth, percentHeight)
	percentWidth = percentWidth or 1
	percentHeight = percentHeight or 1
	local parentSize = container.AbsoluteSize
	local parentCenter = parentSize / 2
	local regionSize = Vector2.new(
		parentSize.X * percentWidth,
		parentSize.Y * percentHeight
	)

	local topLeft = parentCenter - regionSize / 2
	local bottomRight = parentCenter + regionSize / 2
	local randomX = math.random() * (bottomRight.X - topLeft.X) + topLeft.X
	local randomY = math.random() * (bottomRight.Y - topLeft.Y) + topLeft.Y
	return UDim2.fromScale(randomX / parentSize.X, randomY / parentSize.Y)
end

function ClickGameEffect:GetRandomTargetPos(container, origin, minDist, maxDist, percentWidth, percentHeight)
	local parentSize = container.AbsoluteSize
	percentWidth = percentWidth or 1
	percentHeight = percentHeight or 1

	local parentCenter = parentSize / 2
	local regionSize = Vector2.new(
		parentSize.X * percentWidth,
		parentSize.Y * percentHeight
	)

	local topLeft = parentCenter - regionSize / 2
	local bottomRight = parentCenter + regionSize / 2
	local originPos = Vector2.new(origin.X.Scale * parentSize.X, origin.Y.Scale * parentSize.Y)

	local base = (parentSize.X + parentSize.Y) / 2
	local minPixelDist = minDist * base
	local maxPixelDist = maxDist * base

	for _ = 1, 50 do
		local angle = math.random() * math.pi * 2
		local distance = math.random() * (maxPixelDist - minPixelDist) + minPixelDist
		local offset = Vector2.new(math.cos(angle), math.sin(angle)) * distance
		local candidate = originPos + offset

		if candidate.X >= topLeft.X 
			and candidate.X <= bottomRight.X
			and candidate.Y >= topLeft.Y
			and candidate.Y <= bottomRight.Y then
				return UDim2.fromScale(candidate.X / parentSize.X, candidate.Y / parentSize.Y)
		end
	end

	return origin
end

function ClickGameEffect:MoveToRandomPoint(part, startPos, targetPos, duration, onDone)
	local goal = { Position = targetPos }
	local easingStyles = {
		Enum.EasingStyle.Sine,
		Enum.EasingStyle.Quad,
		Enum.EasingStyle.Quart,
		Enum.EasingStyle.Quint,
	}

	local easingDirections = {
		Enum.EasingDirection.Out,
		Enum.EasingDirection.InOut,
		Enum.EasingDirection.In,
	}

	local easingStyle = easingStyles[math.random(1, #easingStyles)]
	local easingDirection = easingDirections[math.random(1, #easingDirections)]

	local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
	local tween = TweenService:Create(part, tweenInfo, goal)
	tween:Play()

	if onDone then
		tween.Completed:Connect(onDone)
	end

	return tween
end

return ClickGameEffect