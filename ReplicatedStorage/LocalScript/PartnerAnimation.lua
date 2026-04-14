-- 放在 NPC 模型下的 LocalScript
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local npc = script.Parent
local npcHumanoid = npc:WaitForChild("Humanoid")
local npcAnimator = npcHumanoid:WaitForChild("Animator")

-- 彻底禁用 NPC 自带的动画系统（确保同步纯净）
--npcHumanoid.Animate = false
npcHumanoid.AutoRotate = false
npcHumanoid.PlatformStand = true

local animateScript = npc:FindFirstChild("Animate")
if animateScript then
	animateScript.Disabled = true
	animateScript.Parent = nil
end

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- 缓存玩家相关引用，避免每帧查找
local playerHumanoid, playerAnimator

-- 动画缓存与状态记录
local npcTracks = {}
local currentNPCPlayingIds = {}

-- 节流配置（秒）
local SYNC_INTERVAL = 0.1  -- 每秒检查10次，足够流畅且省性能

-- 加载并缓存动画轨道
local function loadAnimation(animationId)
	if not animationId or animationId == "" then return nil end
	if not npcTracks[animationId] then
		local animation = Instance.new("Animation")
		animation.AnimationId = animationId
		npcTracks[animationId] = npcAnimator:LoadAnimation(animation)
	end
	return npcTracks[animationId]
end

-- 停止特定动画轨道
local function stopNPCTrack(animationId)
	local track = npcTracks[animationId]
	if track and track.IsPlaying then
		track:Stop()
	end
end

-- 同步逻辑（被节流调用）
local function syncAnimation()
	if not playerAnimator then return end

	local playerPlayingTracks = playerAnimator:GetPlayingAnimationTracks()
	local playerPlayingIds = {}

	-- 快速收集玩家当前动画ID
	for _, track in ipairs(playerPlayingTracks) do
		local id = track.Animation.AnimationId
		if id and id ~= "" then
			playerPlayingIds[id] = true
		end
	end

	-- 移除NPC中不再播放的动画
	for id in pairs(currentNPCPlayingIds) do
		if not playerPlayingIds[id] then
			stopNPCTrack(id)
			currentNPCPlayingIds[id] = nil
		end
	end

	-- 添加玩家新播放的动画
	for id in pairs(playerPlayingIds) do
		if not currentNPCPlayingIds[id] then
			local track = loadAnimation(id)
			if track then
				track:Play()
				currentNPCPlayingIds[id] = true
			end
		end
	end
end

-- 节流执行函数
local lastSync = 0
local function throttledSync(deltaTime)
	lastSync += deltaTime
	if lastSync >= SYNC_INTERVAL then
		lastSync = 0
		
		--npcHumanoid.WalkSpeed = playerHumanoid.WalkSpeed
		syncAnimation()
	end
end

-- 更新玩家引用（角色重生时调用）
local function updatePlayerReferences(newCharacter)
	character = newCharacter
	playerHumanoid = character and character:FindFirstChild("Humanoid")
	playerAnimator = playerHumanoid and playerHumanoid:FindFirstChild("Animator")

	-- 重置NPC状态
	for id in pairs(currentNPCPlayingIds) do
		stopNPCTrack(id)
	end
	currentNPCPlayingIds = {}
	npcTracks = {}
end

-- 初始化玩家引用
updatePlayerReferences(character)

-- 监听角色重生
player.CharacterAdded:Connect(updatePlayerReferences)

-- 启动节流循环（代替 Heartbeat 每帧调用）
RunService.Heartbeat:Connect(throttledSync)