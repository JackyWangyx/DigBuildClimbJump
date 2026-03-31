local UserInputService = game:GetService("UserInputService")
local HapticService = game:GetService("HapticService")

local VibrationManager = {}

VibrationManager.Strength = {
	Light = 0.2,
	Medium = 0.5,
	Strong = 1.0,
}

local function isMobile()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function isGamepad()
	return UserInputService.GamepadEnabled
end

-- API

-- UI确认操作 (轻微震动)
function VibrationManager:UIConfirm()
	self:Vibrate(VibrationManager.Strength.Light, 0.1)
end

-- UI否认 / 错误 (短促但中等震动)
function VibrationManager:UIDeny()
	self:Vibrate(VibrationManager.Strength.Medium, 0.15)
end

-- UI点击 (轻微震动，用于按钮反馈)
function VibrationManager:UIClick()
	self:Vibrate(VibrationManager.Strength.Light, 0.05)
end

-- 游戏内受击 (中等震动)
function VibrationManager:Hit()
	self:Vibrate(VibrationManager.Strength.Medium, 0.2)
end

-- 游戏内强烈冲撞 (强震动)
function VibrationManager:Crash()
	self:Vibrate(VibrationManager.Strength.Strong, 0.4)
end

-- 游戏内爆炸 (连续脉冲震动)
function VibrationManager:Explosion(pulses)
	pulses = pulses or 3
	task.spawn(function()
		for i = 1, pulses do
			self:Vibrate(VibrationManager.Strength.Strong, 0.15)
			task.wait(0.1)
		end
	end)
end

-- Impl

function VibrationManager:Vibrate(strength, duration, userInputType)
	local power = VibrationManager.Strength[strength] or strength or 0.5
	duration = duration or 0.2

	if isMobile() then
		if HapticService:IsVibrationSupported(Enum.UserInputType.Touch) then
			local supported = HapticService:IsMotorSupported(Enum.UserInputType.Touch, Enum.VibrationMotor.Small)
			if supported then
				HapticService:SetMotor(Enum.UserInputType.Touch, Enum.VibrationMotor.Small, power)
				task.delay(duration, function()
					HapticService:SetMotor(Enum.UserInputType.Touch, Enum.VibrationMotor.Small, 0)
				end)
			end
		end
	elseif isGamepad() then
		-- 手柄，默认使用 Gamepad1
		local gamepad = userInputType or Enum.UserInputType.Gamepad1
		if HapticService:IsVibrationSupported(gamepad) then
			-- 同时震动大/小马达
			HapticService:SetMotor(gamepad, Enum.VibrationMotor.Large, power)
			HapticService:SetMotor(gamepad, Enum.VibrationMotor.Small, power)
			task.delay(duration, function()
				HapticService:SetMotor(gamepad, Enum.VibrationMotor.Large, 0)
				HapticService:SetMotor(gamepad, Enum.VibrationMotor.Small, 0)
			end)
		end
	else
		-- PC 键盘 / 鼠标不支持震动，这里可以加个 Debug 输出
		-- print("当前平台不支持震动")
	end
end

-- 停止震动 (提前打断)
function VibrationManager:Stop(userInputType)
	if isMobile() then
		HapticService:SetMotor(Enum.UserInputType.Touch, Enum.VibrationMotor.Small, 0)
	elseif isGamepad() then
		local gamepad = userInputType or Enum.UserInputType.Gamepad1
		HapticService:SetMotor(gamepad, Enum.VibrationMotor.Large, 0)
		HapticService:SetMotor(gamepad, Enum.VibrationMotor.Small, 0)
	end
end

return VibrationManager
