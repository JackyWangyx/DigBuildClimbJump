local animation = script:WaitForChild('AnimationID')
local humanoid = script.Parent:WaitForChild('Humanoid')

-- 1. 确保使用最新的 Animator
local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
local danceTrack = animator:LoadAnimation(animation)

-- 2. 重要：关闭自动循环，我们要手动控制间隔
danceTrack.Looped = false 

-- 3. 设置随机间隔循环
task.spawn(function() -- 使用 spawn 防止阻塞后续脚本运行
	while true do
		-- 播放动画
		danceTrack:Play()

		-- 等待动画播放完毕 (Wait 并不精准，建议用 Ended:Wait())
		danceTrack.Ended:Wait()

		-- --- 随机间隔设置 ---
		-- math.random(最小秒数, 最大秒数)
		local randomInterval = math.random(3, 8) -- 比如：随机休息 2 到 5 秒
		task.wait(randomInterval)

		-- 如果你想让它有概率“发呆”更久，也可以加逻辑
		-- print("休息了 " .. randomInterval .. " 秒，准备开始下一次动作")
	end
end)