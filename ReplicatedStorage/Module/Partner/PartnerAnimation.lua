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

local playerHumanoid, playerAnimator

-- 动画缓存
local npcTracks = {}
local currentNPCPlayingIds = {}

-- 同步节流
local SYNC_INTERVAL = 0.1
local lastSync = 0

-- 时间同步阈值
local TIME_THRESHOLD = 0.1

-- 动画结束缓冲（解决抖动关键）
local END_BUFFER_TIME = 0.15
local endingBuffer = {}

----------------------------------------------------
-- 工具函数
----------------------------------------------------

local function isIdleAnimation(animationId)
	if not animationId then return false end
	return string.lower(animationId):find("idle") ~= nil
end

local function isValidTrack(track)
	if not track then return false end
	if not track.IsPlaying then return false end
	if track.Length <= 0 then return false end

	-- 快结束也认为不稳定
	if track.TimePosition >= track.Length - 0.05 then
		return false
	end

	return true
end

----------------------------------------------------
-- 加载动画
----------------------------------------------------
local function loadAnimation(animationId)
	if not animationId or animationId == "" then return nil end

	if not npcTracks[animationId] then
		local animation = Instance.new("Animation")
		animation.AnimationId = animationId
		npcTracks[animationId] = npcAnimator:LoadAnimation(animation)
	end

	return npcTracks[animationId]
end

----------------------------------------------------
-- 停止动画
----------------------------------------------------
local function stopNPCTrack(animationId)
	local track = npcTracks[animationId]
	if track and track.IsPlaying then
		track:Stop()
	end
end

----------------------------------------------------
-- 核心同步逻辑
----------------------------------------------------
local function syncAnimation()
	if not playerAnimator then return end

	local playerTracks = playerAnimator:GetPlayingAnimationTracks()

	local playerPlaying = {}

	------------------------------------------------
	-- 收集玩家动画 + 过滤不稳定结束态
	------------------------------------------------
	for _, track in ipairs(playerTracks) do
		local id = track.Animation.AnimationId
		if id and id ~= "" then

			if isValidTrack(track) and not isIdleAnimation(id) then
				playerPlaying[id] = track
				endingBuffer[id] = nil
			else
				-- 标记可能结束
				if not endingBuffer[id] then
					endingBuffer[id] = os.clock()
				end
			end
		end
	end

	------------------------------------------------
	-- 处理“结束缓冲期”
	------------------------------------------------
	for id, t in pairs(endingBuffer) do
		if os.clock() - t > END_BUFFER_TIME then
			playerPlaying[id] = nil
			endingBuffer[id] = nil
		end
	end

	------------------------------------------------
	-- 停止 NPC 多余动画
	------------------------------------------------
	for id in pairs(currentNPCPlayingIds) do
		if not playerPlaying[id] then
			stopNPCTrack(id)
			currentNPCPlayingIds[id] = nil
		end
	end

	------------------------------------------------
	-- 同步动画
	------------------------------------------------
	for id, playerTrack in pairs(playerPlaying) do

		-- Idle 不同步（避免抖动核心点）
		if isIdleAnimation(id) then
			continue
		end

		local npcTrack = npcTracks[id]

		-- 新动画
		if not currentNPCPlayingIds[id] then
			npcTrack = loadAnimation(id)
			if npcTrack then
				npcTrack:Play()
				currentNPCPlayingIds[id] = true
			end
		end

		if npcTrack and playerTrack then

			------------------------------------------------
			-- 速度同步
			------------------------------------------------
			npcTrack:AdjustSpeed(playerTrack.Speed)

			------------------------------------------------
			-- 权重同步
			------------------------------------------------
			npcTrack:AdjustWeight(playerTrack.WeightCurrent)

			------------------------------------------------
			-- TimePosition 平滑同步（避免跳帧抖动）
			------------------------------------------------
			local diff = playerTrack.TimePosition - npcTrack.TimePosition

			if math.abs(diff) > TIME_THRESHOLD then
				npcTrack.TimePosition += diff * 0.35
			end
		end
	end
end

----------------------------------------------------
-- 节流执行
----------------------------------------------------
local function throttledSync(deltaTime)
	lastSync += deltaTime
	--if lastSync >= SYNC_INTERVAL then
		lastSync = 0
		syncAnimation()
	--end
end

----------------------------------------------------
-- 玩家引用更新
----------------------------------------------------
local function updatePlayerReferences(newCharacter)
	character = newCharacter
	playerHumanoid = character and character:FindFirstChild("Humanoid")
	playerAnimator = playerHumanoid and playerHumanoid:FindFirstChild("Animator")

	-- 清空 NPC 动画状态
	for id in pairs(currentNPCPlayingIds) do
		stopNPCTrack(id)
	end

	currentNPCPlayingIds = {}
	npcTracks = {}
	endingBuffer = {}
end

----------------------------------------------------
-- 初始化
----------------------------------------------------
updatePlayerReferences(character)

player.CharacterAdded:Connect(updatePlayerReferences)

----------------------------------------------------
-- 主循环
----------------------------------------------------
RunService.Heartbeat:Connect(throttledSync)