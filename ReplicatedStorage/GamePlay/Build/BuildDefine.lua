local BuildDefine = {}

BuildDefine.PartType = {
	Body = "Body",
	Engine = "Engine",
	Armor = "Armor",
	Energy = "Energy",
	Weapon = "Weapon",
	Seat = "Seat",
	Wheel = "Wheel",
	Normal = "Normal",
}

BuildDefine.DirectionType = {
	Front = 1,
	Right = 2,
	Back = 3,
	left = 4,
}

BuildDefine.DirectionRotation = {
	[1] = Vector3.new(0, 0, 0),
	[2] = Vector3.new(0, 90, 0),
	[3] = Vector3.new(0, 180, 0),
	[4] = Vector3.new(0, 270, 0),
}

BuildDefine.BuildPhase = {
	Disable = 1,
	Edit = 2,
	Remove = 3,
}

BuildDefine.SetTipColor = Color3.fromRGB(0, 4, 255)
BuildDefine.RemoveTipColor = Color3.fromRGB(255, 0, 4)

BuildDefine.PrefabPath = game.ReplicatedStorage.Prefab:FindFirstChild("Build")
BuildDefine.InitPos = Vector3.new(0, 1.5, -40)
BuildDefine.CellSize = 3
BuildDefine.WorkSpaceSize = Vector3.new(16, 16, 16)

return BuildDefine
