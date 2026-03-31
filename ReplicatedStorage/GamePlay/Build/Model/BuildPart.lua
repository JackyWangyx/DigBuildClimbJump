local BuildDefine = require(game.ReplicatedStorage.ScriptAlias.BuildDefine)

local PartDataTemplate = {
	ID = 1,
	Name = "Part",
	Type = BuildDefine.PartType.Engine,
	Rarity = 1,
	Weight = 1,
	Hp = 1,
	MaxSpeed = 1,
	MaxDistance = 100,
	AttackInterval = 1,
	AttackPower = 1,
	AttackRange = 5,
	CostCoin = 100,
	Prefab = "Body"
}

local BuildPart = {}

BuildPart.__index = BuildPart

function BuildPart.new()
	local self = setmetatable({}, BuildPart)
	return self
end

-- Update

function BuildPart:Update(deltaTime)

end

function BuildPart:Handle(buildCell, x, y, z, buildModel)
	
end

return BuildPart
