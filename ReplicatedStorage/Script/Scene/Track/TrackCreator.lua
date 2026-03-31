local ObjectPool = require(game.ReplicatedStorage.ScriptAlias.ObjectPool)
local TrackRoute = require(game.ReplicatedStorage.ScriptAlias.TrackRoute)
local TrackSection = require(game.ReplicatedStorage.ScriptAlias.TrackSection)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local TrackCreator = {}

local CreateInfoTemplate = {
	Name = "",
	Prefab = nil,
	PrefabList = {
		[1] = {
			Prefab = "Level/Rank01/Road_Up",
			Length = 1000,
		},
		[2] = {
			Prefab = "Level/Rank01/Road_Up",
			Length = 1000,
		},
	},
	Angle = 30,
	StartOffset = Vector3.new(0, 0, 0),
	Root = nil,
}

function TrackCreator:Create(createInfo)
	local angleRad = math.rad(createInfo.Angle)
	local sinAngle = math.sin(angleRad)
	local cosAngle = math.cos(angleRad)
	local prefabList = createInfo.PrefabList
	local segmentList = {}
	local currentDist = 0
	local segmentIndex = 1
	
	for i = 1, #prefabList do
		local info = prefabList[i]
		local prefab = info.Prefab
		local thisLength = info.Length

		local segment = nil
		--Util:Test("1 生成预制 "..tostring(i), function()
			segment = ObjectPool:Spawn(prefab)
			segment.Parent = createInfo.Root
			segment.Name = createInfo.Name .. "_" .. segmentIndex
		--end)
		
		--Util:Test("2 设置位置 "..tostring(i), function()
			local centerDist = currentDist + thisLength / 2
			local x = createInfo.StartOffset.X
			local y = createInfo.StartOffset.Y + sinAngle * centerDist
			local z = createInfo.StartOffset.Z - cosAngle * centerDist
			local cf = CFrame.new(x, y, z) * CFrame.Angles(angleRad, 0, 0)
			segment:PivotTo(cf)
		--end)

		table.insert(segmentList, segment)
		currentDist = currentDist + thisLength
		segmentIndex = segmentIndex + 1
	end

	local trackRoute = nil
	--Util:Test("3 计算路径", function()
		trackRoute = TrackRoute.new(segmentList)	
	--end)
	
	local track = {
		CreateInfo = createInfo,
		SegmentList = segmentList,
		TrackRoute = trackRoute,
		Length = trackRoute.Length
	}
	
	return track
end

function TrackCreator:Clear(track)
	for _, segment in ipairs(track.SegmentList) do
		ObjectPool:DeSpawn(segment)
	end
	
	track.CreateInfo = nil
	track.SegmentList = nil
	track.TrackRoute = nil
end

return TrackCreator