local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local Lighting = game:GetService("Lighting")
local UserGameSettings = UserSettings().GameSettings

local PerformanceUtil = {}

-- FPS

local FPS = 0

local WINDOW = 120
local dts = table.create(WINDOW)
local head, count = 0, 0
local sumDt = 0

local updateAccum = 0
local UPDATE_INTERVAL = 0.25

function PerformanceUtil:UpdateFPS(deltaTime)
	head = (head % WINDOW) + 1
	if count == WINDOW then
		local old = dts[head]
		if old then
			sumDt -= old
		end
	else
		count += 1
	end
	dts[head] = deltaTime
	sumDt += deltaTime

	updateAccum += deltaTime
	if updateAccum >= UPDATE_INTERVAL then
		local fps = (count > 0 and sumDt > 0) and (count / sumDt) or 0
		FPS = fps
		updateAccum = 0
	end

	
end

function PerformanceUtil:GetFPS()
	return FPS
end

-- Auto Performance

local CHECK_INTERVAL = 2
local LOW_FPS = 60
local HIGH_FPS = 120
local lastCheck = 0

local qualityLevel = "High"    -- "High" | "Medium" | "Low"

PerformanceUtil.QualityLevelType = {
	High = "High",
	Medium = "Medium",
	Low = "Low",
}

function PerformanceUtil:SetGraphics(level)
	if level == qualityLevel then return end
	qualityLevel = level

	if level == PerformanceUtil.QualityLevelType.High then
		UserGameSettings.GraphicsQuality = 1

	elseif level == PerformanceUtil.QualityLevelType.Medium then
		UserGameSettings.GraphicsQuality = 5

	elseif level == PerformanceUtil.QualityLevelType.Low then
		UserGameSettings.GraphicsQuality = 10
	end

	warn("[Performance] Switched to:", level)
end

-- 初始化监控
function PerformanceUtil:UpdatePerformance(deltaTime)
	local now = time()
	if now - lastCheck >= CHECK_INTERVAL then
		lastCheck = now

		if FPS < LOW_FPS and qualityLevel ~= PerformanceUtil.QualityLevelType.Low then
			PerformanceUtil:SetGraphics(PerformanceUtil.QualityLevelType.Low)
		elseif FPS < HIGH_FPS and qualityLevel == PerformanceUtil.QualityLevelType.High then
			PerformanceUtil:SetGraphics(PerformanceUtil.QualityLevelType.Medium)
		elseif FPS > HIGH_FPS and qualityLevel ~= PerformanceUtil.QualityLevelType.High then
			PerformanceUtil:SetGraphics(PerformanceUtil.QualityLevelType.High)
		end
	end
end

UpdatorManager:RenderStepped(function(deltaTime)
	PerformanceUtil:UpdateFPS(deltaTime)
	--PerformanceUtil:UpdatePerformance(deltaTime)
end)

return PerformanceUtil
