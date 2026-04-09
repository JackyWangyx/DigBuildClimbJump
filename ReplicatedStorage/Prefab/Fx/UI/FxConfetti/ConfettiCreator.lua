local ConfettiCreator = {}

-- ✅ confetti 粒子贴图
local imageId = "rbxassetid://131360845497471"

-- 🎨 彩带颜色池
local confettiColors = {
	Color3.fromRGB(255, 0, 0),
	Color3.fromRGB(255, 170, 0),
	Color3.fromRGB(255, 255, 0),
	Color3.fromRGB(0, 255, 0),
	Color3.fromRGB(0, 0, 255),
	Color3.fromRGB(170, 0, 255),
	Color3.fromRGB(255, 0, 255),
	Color3.fromRGB(0, 255, 255),
}

-- ♻️ 对象池
local confettiPool = {}

-- 🧱 创建新粒子（仅池中无可用时调用）
local function createNewConfetti()
	local confetti = Instance.new("ImageLabel")
	confetti.Name = "ConfettiBlock"
	confetti.BackgroundTransparency = 1
	confetti.Image = imageId
	confetti.AnchorPoint = Vector2.new(0.5, 0.5)
	confetti.Visible = false
	confetti.ZIndex = 10
	confetti.ClipsDescendants = false
	return confetti
end

-- 🚿 从池中获取粒子
local function getConfetti(container)
	for _, confetti in ipairs(confettiPool) do
		if not confetti.Visible then
			confetti.Parent = container
			return confetti
		end
	end
	local newOne = createNewConfetti()
	newOne.Parent = container
	table.insert(confettiPool, newOne)
	return newOne
end

-- 🎉 播放彩带特效
function ConfettiCreator.create(origin: UDim2, count: number)
	local gui = script.Parent
	local tweenService = game:GetService("TweenService")
	local container = gui:FindFirstChild("MainFrame") or gui -- ✅ 支持 MainFrame

	local duration = 1
	local interval = duration / count

	for i = 1, count do
		task.delay((i - 1) * interval, function()
			local size = math.random(20, 50)
			local randomX = math.random()
			local startY = -0.3 + math.random() * 0.2
			local endY = 1.2 + math.random() * 0.5

			local confettiOrigin = UDim2.new(randomX, 0, startY, 0)
			local confetti = getConfetti(container)

			confetti.Size = UDim2.new(0, size, 0, size)
			confetti.Position = confettiOrigin
			confetti.ImageColor3 = confettiColors[math.random(1, #confettiColors)]
			confetti.Rotation = 0 -- ✅ 不使用初始旋转
			confetti.Visible = true
			confetti.ImageTransparency = 0

			local offsetX = (math.random() - 0.5) * 0.2
			local tweenTime = math.random(2.2, 2.8)

			local tween = tweenService:Create(confetti, TweenInfo.new(tweenTime, Enum.EasingStyle.Quad), {
				Position = UDim2.new(confetti.Position.X.Scale + offsetX, 0, endY, 0),
				Rotation = confetti.Rotation + math.random(-360, 360),
				Size = UDim2.new(0, size * 0.8, 0, size * 0.8),
			})

			tween:Play()

			tween.Completed:Once(function()
				task.delay(0.3, function()
					if confetti then
						confetti.Visible = false
					end
				end)
			end)
		end)
	end
end

return ConfettiCreator
