local LerpUtil = {}

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
	return Color3.fromHSV(h, s, v)
end

function LerpUtil:Lerp(from, to, factor)
	factor = math.clamp(factor, 0, 1)
	local result = LerpUtil:LerpUnclamped(from, to, factor)
	return result
end

function LerpUtil:LerpUnclamped(from, to, factor)
	if typeof(from) == "number" then
		local result = from + (to - from) * factor
		return result
	elseif typeof(from) == "Vector2" or typeof(from) == "Vector3" then
		local result = from:Lerp(to, factor)
		return result
	elseif typeof(from) == "Color3" then
		return LerpUtil:LerpHSV(from, to, factor)
	elseif typeof(from) == "UDim2" then
		local xs = from.X.Scale   + (to.X.Scale   - from.X.Scale)   * factor
		local xo = from.X.Offset  + (to.X.Offset  - from.X.Offset)  * factor
		local ys = from.Y.Scale   + (to.Y.Scale   - from.Y.Scale)   * factor
		local yo = from.Y.Offset  + (to.Y.Offset  - from.Y.Offset)  * factor
		return UDim2.new(xs, xo, ys, yo)
	elseif typeof(from) == "CFrame" then
		return from:Lerp(to, factor)
	else
		error("LerpUtil: unsupported type " .. typeof(from))
	end
end

function LerpUtil:MoveTowards(from, to, factor)
	if typeof(from) == "number" then
		local delta = to - from
		if math.abs(delta) <= factor then
			return to
		end
		return from + math.sign(delta) * factor
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
