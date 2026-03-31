local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)

-- 客户端通过控制 TargetPart 的位置，玩家保持物理状态，由约束拉动玩家移动，实现平滑移动和同步
-- 服务端只需要授予玩家客户端控制权限
local PlayerMove = {}

PlayerMove.TargetPart = nil
PlayerMove.AlignPosition = nil
PlayerMove.AlignOrientation = nil
PlayerMove.IsClientActive = false

function PlayerMove:Enable(player)
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	if not rootPart then return end
	
	if RunService:IsClient() then
		if PlayerMove.IsClientActive then return end
		-- RootPart的Attachment0（默认有RootRigAttachment，无需新建）
		local attach0 = rootPart:FindFirstChild("RootRigAttachment") or Instance.new("Attachment")
		if not attach0.Parent then
			attach0.Name = "RootRigAttachment"
			attach0.Parent = rootPart
		end

		-- 创建虚拟目标Part（透明、Anchored、小尺寸）
		local targetPart = Instance.new("Part")
		targetPart.Name = "PlayerMove_TargetPart"
		targetPart.Size = Vector3.new(0.1, 0.1, 0.1)
		targetPart.Transparency = 1
		targetPart.CanCollide = false
		targetPart.Anchored = true
		targetPart.CFrame = rootPart.CFrame
		targetPart.Parent = workspace

		local attach1 = Instance.new("Attachment")
		attach1.Parent = targetPart

		local alignPos = Instance.new("AlignPosition")
		alignPos.Attachment0 = attach0
		alignPos.Attachment1 = attach1
		alignPos.MaxForce = math.huge
		alignPos.MaxVelocity = math.huge
		alignPos.Responsiveness = 2000000
		alignPos.Parent = rootPart

		PlayerMove.AlignPosition = alignPos

		local alignOri = Instance.new("AlignOrientation")
		alignOri.Attachment0 = attach0
		alignOri.Attachment1 = attach1
		alignOri.MaxTorque = math.huge
		alignOri.MaxAngularVelocity = math.huge
		alignOri.Responsiveness = 2000000
		alignOri.Parent = rootPart

		PlayerMove.AlignOrientation = alignOri
		
		PlayerMove.TargetPart = targetPart
		
		PlayerManager:DisableControl(player)
		PlayerMove.IsClientActive = true
	else
		rootPart.Anchored = false
		rootPart:SetNetworkOwner(player)
		local humanoid = PlayerManager:GetHumanoid(player)
		humanoid.PlatformStand = true
	end
	
	PlayerManager:DisablePhysic(player)
end

function PlayerMove:Disable(player)
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	if not rootPart then return end

	rootPart.AssemblyLinearVelocity = Vector3.zero
	rootPart.AssemblyAngularVelocity = Vector3.zero
	
	if RunService:IsClient() then
		if not PlayerMove.IsClientActive then return end
	
		--if PlayerMove.TargetPart then
		--	PlayerMove.TargetPart.CFrame = rootPart.CFrame
		--	RunService.Heartbeat:Wait()
		--end
	
		if PlayerMove.AlignPosition then 
			PlayerMove.AlignPosition.Responsiveness = 0
			PlayerMove.AlignPosition.Enabled = false
		end

		if PlayerMove.AlignOrientation then 
			PlayerMove.AlignOrientation.Responsiveness = 0
			PlayerMove.AlignPosition.Enabled = false
		end
		
		RunService.Heartbeat:Wait()
		--rootPart.Anchored = true

		if PlayerMove.AlignPosition then 
			PlayerMove.AlignPosition:Destroy() 
		end

		if PlayerMove.AlignOrientation then 
			PlayerMove.AlignOrientation:Destroy() 
		end

		if PlayerMove.TargetPart then 
			PlayerMove.TargetPart:Destroy()
			PlayerMove.TargetPart = nil
		end
		
		RunService.Heartbeat:Wait()
		rootPart.AssemblyLinearVelocity = Vector3.zero
		rootPart.AssemblyAngularVelocity = Vector3.zero
		
		--rootPart.Anchored = false
		
		PlayerManager:EnableControl(player)
		PlayerMove.IsClientActive = false
	else
		--rootPart:SetNetworkOwner(nil)
		local humanoid = PlayerManager:GetHumanoid(player)
		humanoid.PlatformStand = false
	end
	
	rootPart.AssemblyLinearVelocity = Vector3.zero
	rootPart.AssemblyAngularVelocity = Vector3.zero
	
	PlayerManager:EnablePhysic(player)
end

function PlayerMove:PushPlayer(player, direction, power, delay)
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	local humanoid = PlayerManager:GetHumanoid(player)
	if not rootPart or not humanoid then return end

	-- 多清零（保险）
	rootPart.AssemblyLinearVelocity = Vector3.zero
	rootPart.AssemblyAngularVelocity = Vector3.zero

	local fromPos = rootPart.CFrame.Position
	local targetDirection = direction.Unit
	local newCFrame = CFrame.new(fromPos, fromPos + targetDirection)

	-- 关键：临时 Anchored 设置 CFrame（消除瞬移 velocity）
	local wasAnchored = rootPart.Anchored
	rootPart.Anchored = true
	rootPart.CFrame = newCFrame
	rootPart.Anchored = wasAnchored
	rootPart.AssemblyLinearVelocity = Vector3.zero
	rootPart.AssemblyAngularVelocity = Vector3.zero

	if power > 0 then
		-- 用 LinearVelocity（稳定抛物线，无飞出）
		local attach = rootPart:FindFirstChild("RootRigAttachment") or Instance.new("Attachment", rootPart)
		attach.Name = "RootRigAttachment"

		local lv = Instance.new("LinearVelocity")
		lv.Attachment0 = attach
		lv.RelativeTo = Enum.ActuatorRelativeTo.World
		lv.VectorVelocity = Vector3.new(targetDirection.X * power, 0, targetDirection.Z * power)  -- 只 XZ，重力自由
		lv.MaxForce = math.huge
		lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
		lv.Parent = rootPart

		Debris:AddItem(lv, delay)
	else
		-- power=0：等一帧彻底稳定
		RunService.Heartbeat:Wait()
		rootPart.AssemblyLinearVelocity = Vector3.zero
		rootPart.AssemblyAngularVelocity = Vector3.zero
	end

	-- 立即恢复（避状态切换 lag）
	humanoid.PlatformStand = false
	humanoid:ChangeState(Enum.HumanoidStateType.Running)

	-- 最终清零
	task.wait()
	rootPart.AssemblyLinearVelocity = Vector3.zero
	rootPart.AssemblyAngularVelocity = Vector3.zero
end

return PlayerMove
