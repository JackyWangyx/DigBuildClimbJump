local LerpUtil = {}

-- 缓存函数引用
local clamp = math.clamp
local abs = math.abs
local sign = math.sign

local Color3_new = Color3.new
local Color3_fromHSV = Color3.fromHSV

local UDim2_new = UDim2.new

function LerpUtil:LerpHSV(c1: Color3, c2: Color3, t: number): Color3
	local h1, s1, v1 = c1:ToHSV()
	local h2, s2, v2 = c2:ToHSV()
	local dh = h2 - h1
	if dh > 0.5 then
		h1 += 1
	elseif dh < -0.5 then
		h2 += 1
	end

	local h = h1 + (h2 - h1) * t
	h = h % 1
	local s = s1 + (s2 - s1) * t
	local v = v1 + (v2 - v1) * t
	return Color3_fromHSV(h, s, v)
end

function LerpUtil:Lerp(from, to, factor)
	factor = clamp(factor, 0, 1)
	local result = LerpUtil:LerpUnclamped(from, to, factor)
	return result
end

------------------------------------------------------------------------------------------
-- Lerp Unclamped

function LerpUtil:LerpUnclamped(from, to, factor)
	local typeName = typeof(from)
	if typeName == "number" then
		return LerpUtil:LerpUnclampedValue(from, to, factor)
	elseif typeName == "Vector2" then
		return LerpUtil:LerpUnclampedVector2(from, to, factor)
	elseif typeName == "Vector3" then
		return LerpUtil:LerpUnclampedVector3(from, to, factor)
	elseif typeName == "Color3" then
		return LerpUtil:LerpUnclampedColor3(from, to, factor)
	elseif typeName == "UDim2" then
		return LerpUtil:LerpUnclampedUDim2(from, to, factor)
	elseif typeName == "CFrame" then
		return LerpUtil:LerpUnclampedCFrame(from, to, factor)
	else
		error("LerpUtil: unsupported type ", typeName)
		return from
	end
end

function LerpUtil:LerpUnclampedValue(from, to, factor)
	local result = from + (to - from) * factor
	return result
end

function LerpUtil:LerpUnclampedVector2(from, to, factor)
	return from:Lerp(to, factor)
end

function LerpUtil:LerpUnclampedColor3(from, to, factor)
	return LerpUtil:LerpHSV(from, to, factor)
end

function LerpUtil:LerpUnclampedVector3(from, to, factor)
	return from:Lerp(to, factor)
end

function LerpUtil:LerpUnclampedUDim2(from, to, factor)
	local xs = from.X.Scale   + (to.X.Scale   - from.X.Scale)   * factor
	local xo = from.X.Offset  + (to.X.Offset  - from.X.Offset)  * factor
	local ys = from.Y.Scale   + (to.Y.Scale   - from.Y.Scale)   * factor
	local yo = from.Y.Offset  + (to.Y.Offset  - from.Y.Offset)  * factor
	return UDim2_new(xs, xo, ys, yo)
end

function LerpUtil:LerpUnclampedCFrame(from, to, factor)
	return from:Lerp(to, factor)
end

------------------------------------------------------------------------------------------
-- MoveTowards

function LerpUtil:MoveTowards(from, to, factor)
	if typeof(from) == "number" then
		local delta = to - from
		if abs(delta) <= factor then
			return to
		end
		return from + sign(delta) * factor
	elseif typeof(from) == "Vector3" or typeof(from) == "Vector2" then
		local delta = to - from
		local distance = delta.Magnitude
		if distance <= factor then
			return to
		end
		return from + delta.Unit * factor
	else
		error("LerpUtil: unsupported type " .. typeof(from))
	end
end

return LerpUtil