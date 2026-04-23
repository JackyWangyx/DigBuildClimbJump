local Define = require(game.ReplicatedStorage.Define)

local VersionUtil = {}

function VersionUtil:GetVersion()
	return Define.Version
end

function VersionUtil:Compare(v1, v2)
	if typeof(v1) ~= "string" or typeof(v2) ~= "string" then
		return nil, "Version must be number"
	end

	-- 拆分成数字段（年,月,日,序号）
	local function parseVersion(ver)
		local parts = {}
		for num in string.gmatch(ver, "%d+") do
			table.insert(parts, tonumber(num))
		end
		if #parts ~= 4 then
			return nil, "Version format errer : YYYY.MM.DD.Build"
		end
		return parts
	end

	local p1, err1 = parseVersion(v1)
	local p2, err2 = parseVersion(v2)

	if not p1 then return nil, err1 end
	if not p2 then return nil, err2 end

	for i = 1, 4 do
		if p1[i] > p2[i] then
			return 1
		elseif p1[i] < p2[i] then
			return -1
		end
	end

	return 0
end

return VersionUtil
