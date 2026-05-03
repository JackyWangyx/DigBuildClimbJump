local UserInputService =  game:GetService("UserInputService")
local GroupService = game:GetService("GroupService")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local PhysicsService = game:GetService("PhysicsService")

local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local RobloxUtil = require(game.ReplicatedStorage.ScriptAlias.RobloxUtil)

local Define = require(game.ReplicatedStorage.Define)

local PlayerManager = {}

local OnlinePlayerCache = {} -- 在线玩家缓存，用于快速查找

local PlayerPrefs = nil
local IsClient = nil
local IsServer = nil

PlayerManager.DefaultMoveHeight = 3

local HeadIconCache = {}

function PlayerManager:Init()
	IsClient = RunService:IsClient()
	IsServer = not IsClient
	
	PlayerManager:HandlePlayerAddRemove(function(player)
		OnlinePlayerCache[player.UserId] = player
	end, function(player)
		OnlinePlayerCache[player.UserId] = nil
	end)
	
	if IsClient then
		-- Client
		local player = game.Players.LocalPlayer
		while not player or not player.Character do
			player = game.Players.LocalPlayer
			task.wait()
		end

		PlayerManager:HandleCharacterAddRemove(function(player, character)
			task.wait()		
			RobloxUtil:DisableResetButton()

		end, function(player, character)
			
		end)
	else	
		-- Server
		game.Players.CharacterAutoLoads = true
		PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
		PlayerManager:HandlePlayerAddRemove(function(player)
			AnalyticsManager:Event(player, AnalyticsManager.Define.PlayerLogin)
			
			-- 预缓存头像图标
			PlayerManager:GetHeadIconAsync(player)
			
			--local policy = RobloxUtil:GetPlayerPolicy(player)
			--print(policy)
		end, function(player)
			local playerAnimation = require(game.ReplicatedStorage.ScriptAlias.PlayerAnimation)
			playerAnimation:ClearPlayerAnimationCache(player)
			HeadIconCache[player] = nil
		end)
		
		PlayerManager:HandleCharacterAddRemove(function(player, character)
			-- 关闭玩家间碰撞
			PlayerManager:SetPhysicGroup(player, "PlayerGroup")
		end, function(player, character)
			local playerAnimation = require(game.ReplicatedStorage.ScriptAlias.PlayerAnimation)
			playerAnimation:ClearPlayerAnimationCache(player)
		end)
	end
end

function PlayerManager:HandlePlayerAddRemove(onPlayerAdd, onPlayerRemove, requireSaveLoaded)
	if onPlayerAdd then
		local playerList = game.Players:GetPlayers()
		for _, existPlayer in ipairs(playerList) do
			PlayerManager:OnPlayerAdded(existPlayer, onPlayerAdd, requireSaveLoaded)
		end
		
		game.Players.PlayerAdded:Connect(function(enterPlayer)
			PlayerManager:OnPlayerAdded(enterPlayer, onPlayerAdd, requireSaveLoaded)
		end)
	end
	
	if onPlayerRemove then 
		game.Players.PlayerRemoving:Connect(function(leavePlayer)
			PlayerManager:OnPlayerRemove(leavePlayer, onPlayerRemove, false)
		end)
	end	
end

function PlayerManager:HandleCharacterAddRemove(onCharacterAdd, onCharacterRemove, requireSaveLoaded)
	local function bindCharacterEvents(player)
		if player.Character and onCharacterAdd then
			PlayerManager:OnCharacterAdded(player, player.Character, onCharacterAdd, requireSaveLoaded)
		end
		
		if onCharacterAdd then
			player.CharacterAdded:Connect(function(character)
				PlayerManager:OnCharacterAdded(player, character, onCharacterAdd, requireSaveLoaded)
			end)
		end
		
		if onCharacterRemove then
			player.CharacterRemoving:Connect(function(character)
				PlayerManager:OnCharacterRemove(player, character, onCharacterRemove, false)
			end)
		end
	end

	for _, player in ipairs(game.Players:GetPlayers()) do
		bindCharacterEvents(player)
	end

	game.Players.PlayerAdded:Connect(bindCharacterEvents)
end

--------------------------------------------------------------------------------------------------
-- Login (Server Only)

local function ExecuteWithSaveCheck(requireSaveLoaded, func, ...)
	if IsClient then
		func(...)
	else
		if requireSaveLoaded == nil then
			requireSaveLoaded = true
		end
		if requireSaveLoaded then
			local player = select(1, ...)
			local args = table.pack(...)
			task.spawn(function()
				if not PlayerPrefs then
					PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
				end
				PlayerPrefs:WaitForPlayerSaveLoaded(player)
				func(table.unpack(args, 1, args.n))			
			end)
		else
			func(...)
		end
	end
end

function PlayerManager:OnPlayerAdded(player, func, requireSaveLoaded)
	ExecuteWithSaveCheck(requireSaveLoaded, func, player)
end

function PlayerManager:OnPlayerRemove(player, func, requireSaveLoaded)
	ExecuteWithSaveCheck(requireSaveLoaded, func, player)
end

function PlayerManager:OnCharacterAdded(player, character, func, requireSaveLoaded)
	ExecuteWithSaveCheck(requireSaveLoaded, func, player, character)
end

function PlayerManager:OnCharacterRemove(player, character, func, requireSaveLoaded)
	ExecuteWithSaveCheck(requireSaveLoaded, func, player, character)
end

--------------------------------------------------------------------------------------------------
-- Project

function PlayerManager:IsProjectOwner(player)
	local isGroupGame = (game.CreatorType == Enum.CreatorType.Group)
	local ownerId = game.CreatorId
	if isGroupGame then
		-- 群组项目：检查玩家群组权限
		local success, rank = pcall(function()
			return player:GetRankInGroup(game.CreatorId)
		end)
		return success and (rank >= 255) -- Owner权限
	else
		-- 个人项目：直接比对UserID
		return player.UserId == ownerId
	end
end

--------------------------------------------------------------------------------------------------
-- HeadIcon

function PlayerManager:GetHeadIconAsync(player, callback)
	if not player then return nil end
	local userId = player.UserId
	local cacheIcon = HeadIconCache[player] 
	if cacheIcon then 
		if callback then
			callback(cacheIcon)
		end
		return
	end
	
	task.defer(function()
		local icon, isReady = game.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
		if isReady and player and player:IsDescendantOf(game.Players) then
			HeadIconCache[player] = icon
			if callback then
				callback(icon)
			end
		end
	end)
end

--------------------------------------------------------------------------------------------------
-- ID

function PlayerManager:GetPlayerById(playerId)
	if not playerId then return nil end
	local player = OnlinePlayerCache[playerId]
	return player
end

function PlayerManager:IsPlayerInServerById(playerId)
	local player = OnlinePlayerCache[playerId]
	return player ~= nil
end

--------------------------------------------------------------------------------------------------
-- Get Part

function PlayerManager:GetPlayer()
	local player = game.Players.LocalPlayer
	return player
end

function PlayerManager:GetCharacter(player, timeout)
	timeout = timeout or 3
	if not player then return nil end
	if player.Character then
		return player.Character
	end

	local character
	local startTime = tick()
	while not character and tick() - startTime < timeout do
		character = player.Character
		if character then break end
		task.wait()
	end

	return character
end

function PlayerManager:GetHumanoid(player)
	local character = PlayerManager:GetCharacter(player)
	if not character then return nil end
	local humanoid = character:WaitForChild("Humanoid", 1)
	return humanoid
end

function PlayerManager:GetHumanoidRootPart(player)
	local character = PlayerManager:GetCharacter(player)
	if not character then return nil end
	local rootPart = character:WaitForChild("HumanoidRootPart", 1)
	return rootPart
end

--------------------------------------------------------------------------------------------------
-- Move

function PlayerManager:SetMoveHeight(player, height)
	local humanoid = PlayerManager:GetHumanoid(player)
	if humanoid then
		humanoid.HipHeight = height
	end
end

function PlayerManager:SetDefaultMoveHeight(player)
	PlayerManager:SetMoveHeight(player, PlayerManager.DefaultMoveHeight)
end

function PlayerManager:SetHeight(player, targetHeight)
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart")
	local pos = root.Position
	root.CFrame = CFrame.new(pos.X, targetHeight, pos.Z)
end

--------------------------------------------------------------------------------------------------
-- Spawn

function PlayerManager:SetSpawnLocation(player)
	if not player then return end
	local spawnLocation = game.Workspace:FindFirstChild("SpawnLocation")
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	if not rootPart then return end
	rootPart.Anchored = true
	task.wait()
	local pos = nil
	if spawnLocation then
		pos = spawnLocation.Position
	else
		pos = Vector3.new(0, 20, 0)
	end
	pos = Vector3.new(pos.X, 20, pos.Z)

	workspace.CurrentCamera.CFrame = CFrame.new(pos + Vector3.new(0, 20, 0))
	task.wait()

	rootPart.CFrame = CFrame.new(pos)
	task.delay(0.2, function()
		rootPart.Anchored = false
	end)
end

--------------------------------------------------------------------------------------------------
-- Humanoid

function PlayerManager:DisableHumanoid(humanoid)
	local disableStates = {
		Enum.HumanoidStateType.FallingDown,
		Enum.HumanoidStateType.Ragdoll,
		Enum.HumanoidStateType.GettingUp,
		Enum.HumanoidStateType.Running,
		Enum.HumanoidStateType.RunningNoPhysics,
		Enum.HumanoidStateType.Climbing,
		Enum.HumanoidStateType.Swimming,
		Enum.HumanoidStateType.Seated,
		Enum.HumanoidStateType.PlatformStanding,
	}

	for _, state in ipairs(disableStates) do
		humanoid:SetStateEnabled(state, false)
	end

	-- 不要自动旋转
	humanoid.AutoRotate = false

	-- 切到 PHYSICS 模式，让它不受控制行为影响
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)
end

--------------------------------------------------------------------------------------------------
-- Inupt

function PlayerManager:GetControl(player)
	local PlayerModule = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
	local controls = PlayerModule:GetControls()
	return controls
end

function PlayerManager:EnableControl(player)
	--PlayerManager:EnableMove(player)
	--PlayerManager:EnableJump(player)
	local playerModule = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
	local controls = playerModule:GetControls()
	controls:Enable()
end

function PlayerManager:DisableControl(player)
	--PlayerManager:DisableMove(player)
	--PlayerManager:DisableJump(player)
	local playerModule = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
	local controls = playerModule:GetControls()
	controls:Disable()
end

function PlayerManager:EnableMove(player)
	local humanoid = PlayerManager:GetHumanoid(player)
	if not humanoid then return end
	humanoid.WalkSpeed = Define.Game.WalkSpeed
end

function PlayerManager:DisableMove(player)
	local humanoid = PlayerManager:GetHumanoid(player)
	if not humanoid then return end
	humanoid.WalkSpeed = 0
end

function PlayerManager:SetPhysicGroup(player, groupName)
	local character = PlayerManager:GetCharacter(player)
	if character then
		for _, obj in ipairs(character:GetDescendants()) do
			if obj:IsA("BasePart") then
				obj.CollisionGroup = groupName
			end
		end
	end
end

function PlayerManager:EnablePhysic(player)
	local humanoidRootPartt = PlayerManager:GetHumanoidRootPart(player)
	if not humanoidRootPartt then return end
	humanoidRootPartt.CanTouch = true
	humanoidRootPartt.CanCollide = true
	humanoidRootPartt.Anchored  = false
	humanoidRootPartt.AssemblyLinearVelocity = Vector3.zero
	humanoidRootPartt.AssemblyAngularVelocity = Vector3.zero
end

function PlayerManager:EnableAnchored(player)
	local humanoidRootPartt = PlayerManager:GetHumanoidRootPart(player)
	if not humanoidRootPartt then return end
	humanoidRootPartt.Anchored  = true
end

function PlayerManager:DisableAnchored(player)
	local humanoidRootPartt = PlayerManager:GetHumanoidRootPart(player)
	if not humanoidRootPartt then return end
	humanoidRootPartt.Anchored  = false
end

function PlayerManager:DisablePhysic(player)
	local humanoidRootPartt = PlayerManager:GetHumanoidRootPart(player)
	if not humanoidRootPartt then return end
	humanoidRootPartt.CanTouch = false
	humanoidRootPartt.CanCollide = false
end

function PlayerManager:DisableJump(player)
	local humanoid = PlayerManager:GetHumanoid(player)
	if not humanoid then return end
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0
end

function PlayerManager:EnableJump(player)
	local humanoid = PlayerManager:GetHumanoid(player)
	if not humanoid then return end
	humanoid.JumpPower = 50 -- 恢复默认跳跃能力
	humanoid.JumpHeight = 7.2
end

-- 声音由本地代码创建，服务端无法直接获取，需要由客户端调用
function PlayerManager:DisableFootstepSounds(player)
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	if not rootPart then return end
	for _, sound in pairs(rootPart:GetDescendants()) do
		if sound:IsA("Sound") and sound.Name == "Running" then
			sound.Volume = 0
		end
	end
end

function PlayerManager:EnableFootstepSounds(player)
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	if not rootPart then return end
	for _, sound in pairs(rootPart:GetDescendants()) do
		if sound:IsA("Sound") and sound.Name == "Running" then
			sound.Volume = 1
		end
	end
end

function PlayerManager:GetPlayerForward(player)
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	if not rootPart then return end
	local forward = rootPart.CFrame.LookVector
	return forward
end

function PlayerManager:ClearMove(player)
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	if rootPart then
		rootPart.Velocity = Vector3.zero
		rootPart.AssemblyLinearVelocity = Vector3.zero
		rootPart.AssemblyAngularVelocity = Vector3.zero
	end
end

--------------------------------------------------------------------------------------------------
-- Transform

function PlayerManager:GetPosition(player)
	local character = PlayerManager:GetCharacter(player)
	if not character then return Vector3.zero end
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	if not rootPart then return Vector3.zero end
	return rootPart.Position
end

function PlayerManager:GetHeight(player)
	local pos = PlayerManager:GetPosition(player)
	return pos.Y
end

function PlayerManager:SetPosition(player, position)
	local character = PlayerManager:GetCharacter(player)
	if not character then return end
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	if not rootPart then return end
	local currentCFrame = rootPart.CFrame
	local rotationOnly = currentCFrame.Rotation
	local newCFrame = CFrame.new(position) * rotationOnly
	rootPart.CFrame = newCFrame
end

function PlayerManager:SetCFrameToPart(player, part, heightOffset)
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	if not rootPart then
		return
	end

	heightOffset = heightOffset or 5
	rootPart.CFrame = part.CFrame * CFrame.new(0, heightOffset, 0)
end

function PlayerManager:SetPositionRoad(player, position)
	position = Vector3.new(position.X, PlayerManager.DefaultMoveHeight, position.Z)
	PlayerManager:SetPosition(player, position)
end

function PlayerManager:SetForward(player, forward)
	local character = PlayerManager:GetCharacter(player)
	if not character then return end
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	if not rootPart then return end
	local position = rootPart.Position
	local flatForward = Vector3.new(forward.X, 0, forward.Z).unit
	local newCFrame = CFrame.new(position) * CFrame.fromMatrix(Vector3.new(), flatForward, Vector3.new(0, 1, 0))
	character:PivotTo(newCFrame)
end

function PlayerManager:SetRotation(player, rotation)
	local character = PlayerManager:GetCharacter(player)
	if not character then return end
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	if not rootPart then return end
	rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, math.rad(rotation.Y), 0)
end

function PlayerManager:SetLookAt(player, position)
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	if not rootPart then return end
	local forward = (position - rootPart.Position)
	PlayerManager:SetForward(player, forward)
end

--------------------------------------------------------------------------------------------------
-- State

function PlayerManager:GetState(player)
	if not player then return Enum.HumanoidStateType.None end
	local humanoid = PlayerManager:GetHumanoid(player)
	local state = humanoid:GetState()
	return state
end

function PlayerManager:IsStateClimbing(player)
	local state = PlayerManager:GetState(player)
	return state == Enum.HumanoidStateType.Climbing
end

function PlayerManager:HandleStateChanged(player, onChange)
	if not player or not onChange then return false end
	local humanoid = PlayerManager:GetHumanoid(player)
	if not humanoid then return false end
	humanoid.StateChanged:Connect(function(oldState, newState)
		onChange(oldState, newState)
	end)
	
	return true
end

function PlayerManager:EnableClimb(player)
	local humanoid = PlayerManager:GetHumanoid(player)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
end

function PlayerManager:DisableClimb(player)
	local humanoid = PlayerManager:GetHumanoid(player)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
end

return PlayerManager