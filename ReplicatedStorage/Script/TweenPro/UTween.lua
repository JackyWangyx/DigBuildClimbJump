local TweenMnaager = require(script.Parent.TweenManager)
local Tweener = require(script.Parent.Tweener)
local TweenEnum = require(script.Parent.TweenEnum)

local UTween = {}

UTween.TweenType = TweenEnum.TweenType
UTween.EaseType = TweenEnum.EaseType
UTween.PlayState = TweenEnum.PlayState
UTween.LoopType = TweenEnum.LoopType
UTween.ForwardType = TweenEnum.ForwardType

local TweenCache = {}

-----------------------------------------------------------------------------------------

function UTween:GetTweenFunction(tweenType)
	local tweenFunction = TweenCache[tweenType]
	if not tweenFunction then
		local scriptFile = script.Parent.Tween:FindFirstChild("Tween"..tweenType)
		tweenFunction = require(scriptFile)
		TweenCache[tweenType] = tweenFunction
	end

	return tweenFunction
end

function UTween:CraeteTweener(tweenType, target, from, to, duration)
	local tweenFunction = UTween:GetTweenFunction(tweenType)
	if duration == nil then
		duration = to
		to = from
		from = tweenFunction:GetValue(nil, target)
	end
	
	local tweener = Tweener.new(tweenType, tweenFunction, target, from, to, duration)
	tweener:Play()
	
	return tweener
end

-----------------------------------------------------------------------------------------
-- Tween API
-----------------------------------------------------------------------------------------

-- Value

function UTween:Value(from, to, duration, callback)
	local tweener = UTween:CraeteTweener(UTween.TweenType.Value, nil, from, to, duration)
		:SetOnUpdate(callback)
	return tweener
end

-- Part

function UTween:PartPosition(target, from, to, duration)
	local tweener = UTween:CraeteTweener(UTween.TweenType.PartPosition, target, from, to, duration)
	return tweener
end

function UTween:PartRotation(target, from, to, duration)
	local tweener = UTween:CraeteTweener(UTween.TweenType.PartRotation, target, from, to, duration)
	return tweener
end

function UTween:PartScale(target, from, to, duration)
	local tweener = UTween:CraeteTweener(UTween.TweenType.PartScale, target, from, to, duration)
	return tweener
end

function UTween:PartColor(target, from, to, duration)
	local tweener = UTween:CraeteTweener(UTween.TweenType.PartColor, target, from, to, duration)
	return tweener
end

-- Model

function UTween:ModelPosition(target, from, to, duration)
	local tweener = UTween:CraeteTweener(UTween.TweenType.ModelPosition, target, from, to, duration)
	return tweener
end

function UTween:ModelRotation(target, from, to, duration)
	local tweener = UTween:CraeteTweener(UTween.TweenType.ModelRotation, target, from, to, duration)
	return tweener
end

function UTween:ModelScale(target, from, to, duration)
	local tweener = UTween:CraeteTweener(UTween.TweenType.ModelScale, target, from, to, duration)
	return tweener
end

-- Player
function UTween:PlayerPosition(target, from, to, duration)
	local tweener = UTween:CraeteTweener(UTween.TweenType.PlayerPosition, target, from, to, duration)
	return tweener
end

function UTween:PlayerRotation(target, from, to, duration)
	local tweener = UTween:CraeteTweener(UTween.TweenType.PlayerRotation, target, from, to, duration)
	return tweener
end

-- Gui

function UTween:GuiColor(target, from, to, duration)
	local tweener = UTween:CraeteTweener(UTween.TweenType.GuiColor, target, from, to, duration)
	return tweener
end

function UTween:GuiAnchor(target, from, to, duration)
	local tweener = UTween:CraeteTweener(UTween.TweenType.GuiAnchor, target, from, to, duration)
	return tweener
end

function UTween:GuiRotation(target, from, to, duration)
	local tweener = UTween:CraeteTweener(UTween.TweenType.GuiRotation, target, from, to, duration)
	return tweener
end

function UTween:GuiPosition(target, from, to, duration)
	local tweener = UTween:CraeteTweener(UTween.TweenType.GuiPosition, target, from, to, duration)
	return tweener
end

function UTween:GuiPositionValue(target, from, to, duration)
	local tweener = UTween:CraeteTweener(UTween.TweenType.GuiPositionValue, target, from, to, duration)
	return tweener
end

function UTween:GuiPositionOffset(target, from, to, duration)
	local tweener = UTween:CraeteTweener(UTween.TweenType.GuiPositionOffset, target, from, to, duration)
	return tweener
end

function UTween:GuiScale(target, from, to, duration)
	local tweener = UTween:CraeteTweener(UTween.TweenType.GuiScale, target, from, to, duration)
	return tweener
end

function UTween:GuiScaleValue(target, from, to, duration)
	local tweener = UTween:CraeteTweener(UTween.TweenType.GuiScaleValue, target, from, to, duration)
	return tweener
end

function UTween:GuiScaleOffset(target, from, to, duration)
	local tweener = UTween:CraeteTweener(UTween.TweenType.GuiScaleOffset, target, from, to, duration)
	return tweener
end

-- UI Special

function UTween:GuiGroupTransparency(target, from, to, duration)
	local tweener = UTween:CraeteTweener(UTween.TweenType.GuiGroupTransparency, target, from, to, duration)
	return tweener
end

-- Camera

function UTween:CameraFOV(target, from, to, duration)
	local tweener = UTween:CraeteTweener(UTween.TweenType.CameraFOV, target, from, to, duration)
	return tweener
end

return UTween
