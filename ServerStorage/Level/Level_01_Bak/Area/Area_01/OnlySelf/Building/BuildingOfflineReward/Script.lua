local model = script.Parent
local animController = model:FindFirstChildOfClass("AnimationController")
if not animController then
	warn("未找到 AnimationController")
	return
end

local animation = animController:FindFirstChildOfClass("Animation")
if not animation then
	warn("未找到 Animation")
	return
end

-- 检查是否已经在播放该动画
local isPlaying = false
for _, track in ipairs(animController:GetPlayingAnimationTracks()) do
	if track.Animation == animation then
		isPlaying = true
		break
	end
end

if not isPlaying then
	local track = animController:LoadAnimation(animation)
	track:Play()
end
