local ContentProvider = game:GetService("ContentProvider")

local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local Define = require(game.ReplicatedStorage.Define)

local PlayerAnimation = {}

PlayerAnimation.AnimationSit = "rbxassetid://2506281703"
PlayerAnimation.AnimationFall = "rbxassetid://507767968"
PlayerAnimation.DefaultAnimationCache = nil

local PlayerAnimationCache = {}

--------------------------------------------------------------------------------------------------------
-- Pre Load

function PlayerAnimation:PreloadAnimation(animationAssetID)
	if Util:IsStrEmpty(animationAssetID) then
		return
	end

	local animation = PlayerAnimation:GetAnimation(animationAssetID)

	task.spawn(function()
		ContentProvider:PreloadAsync({animation})
	end)
end

function PlayerAnimation:PreloadAnimations(animationAssetIDs)
	if typeof(animationAssetIDs) ~= "table" or #animationAssetIDs == 0 then
		return
	end

	local animationsToPreload = {}

	for _, assetID in ipairs(animationAssetIDs) do
		if not Util:IsStrEmpty(assetID) then
			local animation = PlayerAnimation:GetAnimation(assetID)
			table.insert(animationsToPreload, animation)
		end
	end

	if #animationsToPreload > 0 then
		task.spawn(function()
			ContentProvider:PreloadAsync(animationsToPreload)
		end)
	end
end

--------------------------------------------------------------------------------------------------------
-- Cache

function PlayerManager:GetAnimator(player)
	local humanoid = PlayerManager:GetHumanoid(player)
	if not humanoid then return nil end
	local animator = humanoid:WaitForChild("Animator", 1)
	return animator
end

function PlayerAnimation:GetPlayerAnimationCache(player)
	if not player then return nil end
	local cache = PlayerAnimationCache[player]
	if not cache then
		cache = {
			CurrentAnimationTrack = nil,
			CachedAnimateScript = nil
		}

		local character = PlayerManager:GetCharacter(player)
		if character then
			local animate = character:FindFirstChild("Animate")
			if animate and animate:IsA("LocalScript") then
				cache.AnimateScript = animate
			end


		end

		local humanoid = PlayerManager:GetHumanoid(player)
		if humanoid then
			local animator = humanoid:FindFirstChildOfClass("Animator")
			if animator then
				cache.Animator = animator
			end
		end

		PlayerAnimationCache[player] = cache
	end

	return cache
end

function PlayerAnimation:ClearPlayerAnimationCache(player)
	PlayerAnimationCache[player] = nil
end

local AnimationCache = {}

function PlayerAnimation:GetAnimation(animationAssetID)
	if not animationAssetID then return nil end
	local animation = AnimationCache[animationAssetID]
	if not animation then
		animation = Instance.new("Animation")
		animation.AnimationId = animationAssetID
		AnimationCache[animationAssetID] = animation
	end

	return animation
end

--------------------------------------------------------------------------------------------------------
-- Play / Stop

local AnimationFadeInTime = 0.15
local AnimationFadeOutTime = 0.05

local AnimationWeight = 4
local AnimationPriority = Enum.AnimationPriority.Action

function PlayerAnimation:PlayAnimation(player, animationAssetID, loop, speed)
	if Util:IsStrEmpty(animationAssetID) then
		PlayerAnimation:StopAnimation(player, animationAssetID)
		return
	end

	--local character = PlayerManager:GetCharacter(player)
	local humanoid = PlayerManager:GetHumanoid(player)
	if not humanoid then return end

	-- 停掉原来播放的动画
	local cache = PlayerAnimation:GetPlayerAnimationCache(player)
	if cache.CurrentTrack then
		cache.CurrentTrack:Stop(AnimationFadeOutTime)
		--cache.CurrentTrack:Destroy()
		cache.CurrentTrack = nil
	end

	-- 禁用默认 Animate 脚本
	--if cache.AnimateScript then
	--	cache.AnimateScript.Enabled = false

		--local c1 = #humanoid:GetPlayingAnimationTracks()
		--local c2 = #cache.Animator:GetPlayingAnimationTracks()
		--print(c1, c2)
		--print("Disable", player.UserId, cache.AnimateScript.Enabled)
	--end

	-- 停止已有的动画
	--for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
	--	track:Stop(0)
	--	track:Destroy()
	--end

	-- 创建动画对象
	local animation = PlayerAnimation:GetAnimation(animationAssetID)
	local track = cache.Animator:LoadAnimation(animation)
	track.Stopped:Connect(function()
		track:Destroy()
	end)
	
	track.Priority = AnimationPriority
	track.Looped = loop or false
	track:Play(AnimationFadeInTime, AnimationWeight)
	track:AdjustSpeed(speed or 1)

	cache.CurrentTrack = track
	
	if not loop then
		local length = track.Length
		task.delay(length, function()
			if track and track.IsPlaying then
				if cache.CurrentTrack == track then
					cache.CurrentTrack = nil
				end
				
				track:Stop()
			end
		end)
	end
end

function PlayerAnimation:StopAnimation(player, animationAssetID)
	if not player then return end
	-- 停止播放的动画
	local cache = PlayerAnimation:GetPlayerAnimationCache(player)
	if cache and cache.CurrentTrack then
		cache.CurrentTrack:Stop(AnimationFadeOutTime)
		--cache.CurrentTrack:Destroy()
		cache.CurrentTrack = nil
	end

	-- 重新启用 Animate 脚本
	--if cache and cache.AnimateScript then
	--	cache.AnimateScript.Enabled = true
		--print("Enable", player.UserId, cache.AnimateScript.Enabled)
	--end
end

--------------------------------------------------------------------------------------------------------
-- Replace

function PlayerAnimation:ReplaceAllAnimation(player, animationID)
	if not PlayerAnimation.DefaultAnimationCache then 
		PlayerAnimation:SaveInitialAnimations(player)
	end
	local animateScript = PlayerAnimation:GetAnimator(player)
	if not animateScript then return end

	for animParentName, anima in pairs(PlayerAnimation.DefaultAnimationCache) do
		local animParent = Util:GetChildByName(animateScript, animParentName)
		for animName, animaId in pairs(anima) do
			local anime = Util:GetChildByName(animParent, animName)
			anime.AnimationId = animationID
		end	
	end
end


function PlayerAnimation:SaveInitialAnimations(player)
	local animateScript = PlayerAnimation:GetAnimator(player)
	if not animateScript then return end
	PlayerManager.DefaultAnimationCache = {}
	local animationList = Util:GetAllChildByType(animateScript, "Animation")
	for _, anim in pairs(animationList) do
		if not PlayerAnimation.DefaultAnimationCache[anim.Parent.Name] then
			PlayerAnimation.DefaultAnimationCache[anim.Parent.Name] = {}
		end
		PlayerAnimation.DefaultAnimationCache[anim.Parent.Name][anim.Name] = anim.AnimationId
	end
end

function PlayerAnimation:SetAnimateDefault(player)
	if not PlayerAnimation.DefaultAnimationCache then return end
	local animateScript = PlayerAnimation:GetAnimator(player)
	if not animateScript then return end
	for animParentName, anima in pairs(PlayerAnimation.DefaultAnimationCache) do
		local animParent = Util:GetChildByName(animateScript, animParentName)
		for animName, animId in pairs(anima) do
			local anime = Util:GetChildByName(animParent, animName)
			anime.AnimationId = animId
		end	
	end
end

function PlayerAnimation:SetAnimationSpeed(player, speed)
	local humanoid = PlayerManager:GetHumanoid(player)
	if not humanoid then return end
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then return end
	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
		track:AdjustSpeed(speed)
	end
end

return PlayerAnimation
