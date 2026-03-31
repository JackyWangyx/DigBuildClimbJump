local RunService = game:GetService("RunService")
local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local DriveController = {}

local DriveInfo = nil

local SteerAngle = 90
local Speed = 50
local DefaultAccel = 150
local BrakeAccel = 150
local TractionFactor = 1.0
local AngularDamping = 0.5

function DriveController:Init()
	if RunService:IsClient() then
		UpdatorManager:Heartbeat(function(deltaTime)
			DriveController:Update(deltaTime)
		end)
		
		local player = game.Players.LocalPlayer
		local car = DriveController:GetCar(player)
		DriveController:Start(car)
		
		EventManager:Listen(EventManager.Define.DriveStart, function()
			local player = game.Players.LocalPlayer
			local car = DriveController:GetCar(player)
			DriveController:Start(car)
			
			--EventManager:Dispatch(EventManager.Define.RefreshAnimal)
		end)

		EventManager:Listen(EventManager.Define.DriveEnd, function()
			DriveController:End()
		end)
	end
end

function DriveController:Sit(player, car)
	local humanoid = PlayerManager:GetHumanoid(player)
	if not humanoid then return false end
	local seat = car.DriveSeat or car.VehicleSeat or car.Seat
	if not seat then return false end
	seat:Sit(humanoid)
	
	if RunService:IsClient() then
		local player = game.Players.LocalPlayer
		game.Workspace.Camera.CameraSubject = PlayerManager:GetHumanoidRootPart(player)
	end
	
	return true
end

function DriveController:GetPlayerCar(player)
	if not player and RunService:IsClient() then
		player = game.Players.LocalPlayer
	end
	
	local character = PlayerManager:GetCharacter(player)
	local car = character:WaitForChild("Car")
	return car
end

function DriveController:GetCar(player)
	if RunService:IsClient() then
		if DriveInfo then
			return DriveInfo.Root
		end
	end
	
	return DriveController:GetPlayerCar(player)
end

--------------------------------------------------------------------------------
-- Client Only

function DriveController:Start(car)
	if not car then return false end
	if DriveInfo then return false end
	
	DriveInfo = {
		Root = car,
		Seat = car.DriveSeat,
		Wheel = {
			FrontLeft = car.FrontLeft,
			FrontRight = car.FrontRight,
			BackLeft = car.BackLeft,
			BackRight = car.BackRight,
		},
		WheelVelocities = {
			FrontLeft = 0,
			FrontRight = 0,
			BackLeft = 0,
			BackRight = 0
		},
	}
	
	DriveInfo.Seat:GetPropertyChangedSignal("Steer"):Connect(function()
		-- Dynamic steering angle based on speed
		local speedFactor = math.clamp(1 - math.abs(DriveInfo.Seat.Throttle) * 0.5, 0.3, 1) -- Reduce steering at high speeds
		local angle = SteerAngle * DriveInfo.Seat.Steer * speedFactor
		DriveInfo.Wheel.FrontLeft.PartB.SteeringConstraint.TargetAngle = angle
		DriveInfo.Wheel.FrontRight.PartB.SteeringConstraint.TargetAngle = angle
	end)
	
	DriveController:ApplyTraction(car)
	
	return true
end

function DriveController:End()
	DriveInfo = nil
end

function DriveController:Update(deltaTime)
	if not DriveInfo then return end
		
	local throttle = DriveInfo.Seat.Throttle

	-- 前后轮目标速度（左右轮同向）
	local targetFL = Speed * throttle
	local targetFR = -Speed * throttle
	local targetBL = Speed * throttle
	local targetBR = -Speed * throttle

	-- 动态加速度函数
	local function calcVelocity(current, target)
		if math.sign(current) ~= math.sign(target) and current ~= 0 then
			return current + math.clamp(-current, -BrakeAccel * deltaTime, BrakeAccel * deltaTime)
		else
			return current + math.clamp(target - current, -DefaultAccel * deltaTime, DefaultAccel * deltaTime)
		end
	end

	-- 更新轮子速度
	DriveInfo.WheelVelocities.FrontLeft = calcVelocity(DriveInfo.WheelVelocities.FrontLeft, targetFL)
	DriveInfo.WheelVelocities.FrontRight = calcVelocity(DriveInfo.WheelVelocities.FrontRight, targetFR)
	DriveInfo.WheelVelocities.BackLeft = calcVelocity(DriveInfo.WheelVelocities.BackLeft, targetBL)
	DriveInfo.WheelVelocities.BackRight = calcVelocity(DriveInfo.WheelVelocities.BackRight, targetBR)

	-- 应用到轮子
	DriveInfo.Wheel.FrontLeft.Wheel.WheelConstraint.AngularVelocity = DriveInfo.WheelVelocities.FrontLeft
	DriveInfo.Wheel.FrontRight.Wheel.WheelConstraint.AngularVelocity = DriveInfo.WheelVelocities.FrontRight
	DriveInfo.Wheel.BackLeft.Wheel.WheelConstraint.AngularVelocity = DriveInfo.WheelVelocities.BackLeft
	DriveInfo.Wheel.BackRight.Wheel.WheelConstraint.AngularVelocity = DriveInfo.WheelVelocities.BackRight
	
	-- Apply angular damping to reduce drift
	if DriveInfo.Root.Body then
		local bodyAngularVelocity = DriveInfo.Root.Body.AssemblyAngularVelocity
		DriveInfo.Root.Body.AssemblyAngularVelocity = bodyAngularVelocity * AngularDamping
	end
end

function DriveController:RotateWheel(deltaTime)
	if not DriveInfo then return end
	local rotateSpeed = 10
	DriveInfo.Wheel.FrontLeft.Wheel.CFrame = DriveInfo.Wheel.FrontLeft.Wheel.CFrame * CFrame.Angles(rotateSpeed, 0, 0)
	DriveInfo.Wheel.FrontRight.Wheel.CFrame = DriveInfo.Wheel.FrontRight.Wheel.CFrame * CFrame.Angles(rotateSpeed, 0, 0)
	DriveInfo.Wheel.BackLeft.Wheel.CFrame = DriveInfo.Wheel.BackLeft.Wheel.CFrame * CFrame.Angles(rotateSpeed, 0, 0)
	DriveInfo.Wheel.BackRight.Wheel.CFrame = DriveInfo.Wheel.BackRight.Wheel.CFrame * CFrame.Angles(rotateSpeed, 0, 0)
end

function DriveController:ApplyTraction(car)
	if not car then
		car = DriveController:GetCar()
	end
	for _, part in ipairs(car:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Friction = 1.5 -- Increase friction for better grip
			part.Elasticity = 0.1 -- Reduce bounciness
		end
	end
end

local PhysicsCache = {} 

function DriveController:DisablePhysics(car)
	if not car then
		car = DriveController:GetCar()
	end
	if not PhysicsCache[car] then
		PhysicsCache[car] = {}
	end
	for _, part in ipairs(car:GetDescendants()) do
		if part:IsA("BasePart") then
			if not PhysicsCache[car][part] then
				PhysicsCache[car][part] = {
					Anchored = part.Anchored,
					CanCollide = part.CanCollide,
					CanTouch = part.CanTouch,
					Massless = part.Massless,
					Friction = part.Friction,
					Elasticity = part.Elasticity,
				}
			end
			part.CanTouch = false
			part.CanCollide = false
		end
	end
end

function DriveController:EnablePhysics(car)
	if not car then
		car = DriveController:GetCar()
	end
	if not PhysicsCache[car] then return end
	for _, part in ipairs(car:GetDescendants()) do
		local cached = PhysicsCache[car][part]
		if cached then
			if part:IsA("BasePart") then
				part.Anchored = cached.Anchored
				part.CanCollide = cached.CanCollide
				part.Massless = cached.Massless
				part.CanTouch = cached.CanTouch
				part.Friction = cached.Friction
				part.Elasticity = cached.Elasticity
			end
		end
	end
	PhysicsCache[car] = nil
end

return DriveController
