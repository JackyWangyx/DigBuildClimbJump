local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")

local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)

local PathManager = {}

function PathManager:FindPathTo(player, targetPosition, onDone)
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end

	character.PrimaryPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	-- 创建路径
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentJumpHeight = 10,
		AgentMaxSlope = 45,
	})
	
	targetPosition = PathManager:GetSafeTargetPosition(targetPosition)
	path:ComputeAsync(character.PrimaryPart.Position, targetPosition)

	if path.Status ~= Enum.PathStatus.Success then
		onDone(false)
		return
	end

	local waypoints = path:GetWaypoints()
	local index = 1
	local isMoving = true
	local moveConn = nil

	local function moveNext()
		if not isMoving then return end
		if index > #waypoints then
			if onDone then onDone(true) end
			return
		end

		local waypoint = waypoints[index]
		humanoid:MoveTo(waypoint.Position)

		moveConn = humanoid.MoveToFinished:Connect(function(reached)
			moveConn:Disconnect()
			if not isMoving then return end

			if reached then
				index += 1
				moveNext()
			else
				isMoving = false
				if onDone then onDone(false, "MoveTo failed") end
			end
		end)
	end

	-- 提供中止函数
	local function cancel()
		isMoving = false
		if moveConn then moveConn:Disconnect() end
		humanoid:MoveTo(character.PrimaryPart.Position)
		if onDone then onDone(false, "Cancelled") end
	end

	moveNext()

	-- 返回取消控制器
	return {
		cancel = cancel
	}
end

function PathManager:GetSafeTargetPosition(pos)
	local rayOrigin = pos + Vector3.new(0, 10, 0)
	local rayDirection = Vector3.new(0, -50, 0)
	local result = workspace:Raycast(rayOrigin, rayDirection)

	if result then
		return result.Position + Vector3.new(0, 2, 0) -- 稍微高于地面
	else
		return pos -- fallback
	end
end

return PathManager
