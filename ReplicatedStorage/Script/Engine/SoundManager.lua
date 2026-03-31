local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Define = require(game.ReplicatedStorage.Define)

local SoundManager = {}

SoundManager.Define = Define.Sound

local IsInit = false

local SoundCache = {}
local CurrentBGM = nil

function SoundManager:Init()
	if IsInit then return end
	IsInit = true
	self:PlayBGM(self.Define.BGM, true, 0.3)
end

function SoundManager:Load(name)
	if name == nil then return end
	if SoundCache[name] then
		return SoundCache[name]
	end

	local sound = SoundService:FindFirstChild(name)
	if sound then
		SoundCache[name] = sound
		return sound
	else
		warn("[Client] Sound not found: " .. name)
		return nil
	end
end

local LastSFX, LastSFXTime = nil, -1

function SoundManager:PlaySFX(name)
	if not IsInit then return end

	local currentTime = os.clock()
	if LastSFX == name and currentTime - LastSFXTime < Define.Sound.PlaySfxInterval then
		return
	end

	LastSFX, LastSFXTime = name, currentTime

	local sound = self:Load(name)
	if sound then
		local newSound = sound:Clone()
		newSound.Parent = workspace
		newSound:Play()
		Debris:AddItem(newSound, newSound.TimeLength + 1)
	end
end

function SoundManager:PlayBGM(name, looped, volume)
	if not IsInit then return end

	local sound = self:Load(name)
	if not sound then return end

	if CurrentBGM and CurrentBGM.IsPlaying then
		CurrentBGM:Stop()
	end

	CurrentBGM = sound
	CurrentBGM.Looped = (looped ~= false)
	CurrentBGM.Volume = volume or 0.5
	CurrentBGM:Play()
end

function SoundManager:StopBGM()
	if not IsInit or not CurrentBGM then return end
	CurrentBGM:Stop()
	CurrentBGM = nil
end

function SoundManager:FadeOutBGM(duration)
	if not IsInit or not CurrentBGM then return end
	duration = duration or 2

	local tween = TweenService:Create(
		CurrentBGM,
		TweenInfo.new(duration, Enum.EasingStyle.Linear),
		{ Volume = 0 }
	)
	tween:Play()
	tween.Completed:Wait()

	CurrentBGM:Stop()
	CurrentBGM.Volume = 0.5
	CurrentBGM = nil
end

return SoundManager
