local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local TrackSection = {}

TrackSection.__index = TrackSection

function TrackSection.new(segmentInstance)
	local self = setmetatable({}, TrackSection)
	
	self.Instance = segmentInstance
	self:InitPointList()
	--self:InitPath()
	
	return self
end

function TrackSection:InitPointList()
	self.PointList = {}
	local pointList = Util:GetAllChildByNameFuzzy(self.Instance.Path, "Point_", false)
	pointList = Util:ListSortByPartName(pointList)
	
	for _, pointPart in ipairs(pointList) do
		local pointData = {
			Position = pointPart.CFrame.Position,
			Rotation = pointPart.CFrame.Rotation,
		}
		
		table.insert(self.PointList, pointData)
	end
	
	self.Count = #self.PointList
end

--function TrackSection:InitPath()
--	local length = 0
--	for index, point in ipairs(self.PointList) do
--		if index == 1 then 
--			point.Distance = length
--			continue
--		end
--		local p1 = self.PointList[index - 1]
--		local p2 = point
--		local len = (p2.Position - p1.Position).Magnitude
--		length += len
--		point.Distance = length
--	end
	
--	self.Length = length
--end

return TrackSection
