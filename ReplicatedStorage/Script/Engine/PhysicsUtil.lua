local PhysicsService = game:GetService("PhysicsService")

local PhysicsUtil = {}

function PhysicsUtil:SetCharacterCollisionGroup(character, groupName)
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(part, groupName)
		end
	end
end

function PhysicsUtil:Init()
	local groupName = "Player"
	if not PhysicsService:CollisionGroupExists(groupName) then
		PhysicsService:CreateCollisionGroup(groupName)
	end
	
	PhysicsService:CollisionGroupSetCollidable(groupName, groupName, false)
	PhysicsService:CollisionGroupSetCollidable(groupName, "Default", false)

	game.Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			-- 初次创建角色
			PhysicsUtil:SetCharacterCollisionGroup(character)

			-- 角色后续添加的物理部件也处理
			character.DescendantAdded:Connect(function(desc)
				if desc:IsA("BasePart") then
					PhysicsService:SetPartCollisionGroup(desc, groupName)
				end
			end)
		end)
	end)
end

return PhysicsUtil
