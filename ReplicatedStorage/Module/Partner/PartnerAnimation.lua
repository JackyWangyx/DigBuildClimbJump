-- 放在 NPC 模型下的 LocalScript
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local npc = script.Parent
local npcHumanoid = npc:WaitForChild("Humanoid")
local npcAnimator = npcHumanoid:WaitForChild("Animator")

-- 禁用 NPC 自带动画
npcHumanoid.AutoRotate = false
npcHumanoid.PlatformStand = true

local animateScript = npc:FindFirstChild("Animate")
if animateScript then
	animateScript.Disabled = true
	animateScript.Parent = nil
end

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- 玩家引用缓存
local playerHumanoid, playerAnimator

-- 动画缓存
local npcTracks = {}
local currentNPCPlayingIds = {}

-- 节流
local SYNC_INTERVAL = 0.1
local lastSync = 0

-- 时间同步阈值（防抖）
local TIME_THRESHOLD = 0.1

-- 加载动画
local function loadAnimation(animationId)
	if not animationId or animationId == "" then return nil end

	if not npcTracks[animationId] then
		local animation = Instance.new("Animation")
		animation.AnimationId = animationId
		npcTracks[animationId] = npcAnimator:LoadAnimation(animation)
	end

	return npcTracks[animationId]
end

-- 停止动画
local function stopNPCTrack(animationId)
	local track = npcTracks[animationId]
	if track and track.IsPlaying then
		track:Stop()
	end
end

-- 核心同步逻辑
local function syncAnimation()
	if not playerAnimator then return end

	local playerTracks = playerAnimator:GetPlayingAnimationTracks()
	local playerPlaying = {}

	-- 收集玩家动画（带 track）
	for _, playerTrack in ipairs(playerTracks) do
		local id = playerTrack.Animation.AnimationId
		if id and id ~= "" then
			playerPlaying[id] = playerTrack
		end
	end

	-- 停止 NPC 多余动画
	for id in pairs(currentNPCPlayingIds) do
		if not playerPlaying[id] then
			stopNPCTrack(id)
			currentNPCPlayingIds[id] = nil
		end
	end

	-- 同步 / 播放动画
	for id, playerTrack in pairs(playerPlaying) do
		local npcTrack = npcTracks[id]

		-- 新动画 → 播放
		if not currentNPCPlayingIds[id] then
			npcTrack = loadAnimation(id)
			if npcTrack then
				npcTrack:Play()
				currentNPCPlayingIds[id] = true
			end
		end

		if npcTrack then
			-- ✅ 同步速度
			npcTrack:AdjustSpeed(playerTrack.Speed)

			-- ✅ 同步权重
			npcTrack:AdjustWeight(playerTrack.WeightCurrent)

			-- ✅ 同步时间（带阈值）
			if math.abs(npcTrack.TimePosition - playerTrack.TimePosition) > TIME_THRESHOLD then
				npcTrack.TimePosition = playerTrack.TimePosition
			end
		end
	end
end

-- 节流执行
local function throttledSync(deltaTime)
	lastSync += deltaTime
	if lastSync >= SYNC_INTERVAL then
		lastSync = 0
		syncAnimation()
	end
end

-- 更新玩家引用
local function updatePlayerReferences(newCharacter)
	character = newCharacter
	playerHumanoid = character and character:FindFirstChild("Humanoid")
	playerAnimator = playerHumanoid and playerHumanoid:FindFirstChild("Animator")

	-- 重置 NPC 动画
	for id in pairs(currentNPCPlayingIds) do
		stopNPCTrack(id)
	end

	currentNPCPlayingIds = {}
	npcTracks = {}
end

-- 初始化
updatePlayerReferences(character)

-- 监听重生
player.CharacterAdded:Connect(updatePlayerReferences)

-- 启动循环
RunService.Heartbeat:Connect(throttledSync)