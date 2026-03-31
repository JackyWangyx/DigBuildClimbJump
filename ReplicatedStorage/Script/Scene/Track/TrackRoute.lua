local TrackSection = require(game.ReplicatedStorage.ScriptAlias.TrackSection)

local TrackRoute = {}

TrackRoute.__index = TrackRoute

function TrackRoute.new(segmentList, prefabList)
	local self = setmetatable({}, TrackRoute)

	self.SegmentList = segmentList
	--self.PrefabList = prefabList
	self:InitPath()
	
	return self
end

function TrackRoute:InitPath()
	local length = 0
	
	self.SectionList = {}
	for index, segment in ipairs(self.SegmentList) do
		--local prefab = self.PrefabList[index]
		local trackSection = TrackSection.new(segment)
		table.insert(self.SectionList, trackSection)
	end
	
	self.PointList = {}
	local lastPoint = nil
	for sectionIndex, section in ipairs(self.SectionList) do
		for pointIndex, point in ipairs(section.PointList) do
			local len = 0
			if lastPoint then
				len = (point.Position - lastPoint.Position).Magnitude
			end

			lastPoint = point
			length += len
			local pointData = {
				Position = point.Position,
				Rotation = point.Rotation,
				Distance = length,
			}
			
			table.insert(self.PointList, pointData)
		end
	end
	
	self.Length = length
end

function TrackRoute:GetPointByFactor(factor)
	if factor <= 0 then
		return {
			Position = self.PointList[1].Position,
			Rotation = self.PointList[1].Rotation,
		}
	end
	if factor >= 1 then
		return {
			Position = self.PointList[#self.PointList].Position,
			Rotation = self.PointList[#self.PointList].Rotation,
		}
	end
	local distance = factor * self.Length
	return self:GetPointByDistance(distance)
end

local function isValueNaN(x)
	return x ~= x
end

local function isVectorNaN(v)
	if isValueNaN(v.X) or isValueNaN(v.Y) or isValueNaN(v.Z) then
		return true
	else
		return false
	end
end

function TrackRoute:GetPointByDistance(distance)
	distance = math.clamp(distance, 0, self.Length)
	if distance <= 1e-6 then
		return {
			Position = self.PointList[1].Position,
			Rotation = self.PointList[1].Rotation,
		}
	end
	if distance >= self.Length then
		return {
			Position = self.PointList[#self.PointList].Position,
			Rotation = self.PointList[#self.PointList].Rotation,
		}
	end
	for i = 1, #self.PointList - 1 do
		local p1 = self.PointList[i]
		local p2 = self.PointList[i + 1]
		if p1.Distance <= distance and distance < p2.Distance then
			local segDist = p2.Distance - p1.Distance
			if segDist <= 1e-6 then
				return {
					Position = p1.Position,
					Rotation = p1.Rotation,
				}
			end
			local alpha = math.clamp((distance - p1.Distance) / segDist, 0, 1)

			local pos = p1.Position:Lerp(p2.Position, alpha)
			local rot = p1.Rotation:Lerp(p2.Rotation, alpha)

			if isVectorNaN(pos) or isVectorNaN(rot) then 
				return {
					Position = p1.Position,
					Rotation = p1.Rotation,
				}
			end

			return {
				Position = pos,
				Rotation = rot,
			}
		end
	end
	return {
		Position = self.PointList[#self.PointList].Position,
		Rotation = self.PointList[#self.PointList].Rotation,
	}
end

-- 二分查找最近的路径上的位置
function TrackRoute:SearchNearestPos(position, left, right, depth)
	local posLeft = self:GetPointByDistance(left).Position
	local posRight = self:GetPointByDistance(right).Position

	local minSpatialDist1 = (posLeft - position).Magnitude
	local minSpatialDist2 = (posRight - position).Magnitude
	
	local mid = (right - left) / 2 + left
	depth += 1
	
	if math.abs(minSpatialDist1 - minSpatialDist2) < 0.01 then
		return mid
	end
	
	if depth > 50 then
		return mid
	end
	
	if minSpatialDist1 < minSpatialDist2 then
		return self:SearchNearestPos(position, left, mid, depth)
	else
		return self:SearchNearestPos(position, mid, right, depth)
	end	
end

function TrackRoute:GetNearestPathDistance(position)
	if self.Length <= 0 or #self.PointList < 2 then
		return 0
	end

	local left = 0
	local right = self.Length
	local depth = 1
	local distance = self:SearchNearestPos(position, left, right, depth)
	return distance
end

return TrackRoute
