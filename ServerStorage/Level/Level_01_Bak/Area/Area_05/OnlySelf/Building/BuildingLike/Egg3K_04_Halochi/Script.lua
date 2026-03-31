local model = script.Parent
local animController = model:FindFirstChild("AnimationController")
if not animController then
	--warn("没有找到 AnimationController")
	return
end

local animation = animController:FindFirstChildOfClass("Animation")
if not animation then
	--warn("没有找到 Animation 对象")
	return
end

local track = animController:LoadAnimation(animation)
track:Play()
