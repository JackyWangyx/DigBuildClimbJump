local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local TweenServiceManager = require(game.ReplicatedStorage.ScriptAlias.TweenServiceManager)
local UTween = require(game.ReplicatedStorage.ScriptAlias.UTween)
local SoundManager = require(game.ReplicatedStorage.ScriptAlias.SoundManager)
local UIButtonToolTip = require(game.ReplicatedStorage.ScriptAlias.UIButtonTooltip)
local UIIcon = require(game.ReplicatedStorage.ScriptAlias.UIIcon)

local UIButton = {}

UIButton.ConnectionCache = {}
UIButton.SizeInfoCache = {}
UIButton.ClickFuncCache = {}

function UIButton:Handle(button, func, param)
	if not button or not button:IsA("GuiButton") then return end
	if typeof(func) ~= "function" then return end

	self:Clear(button)

	-- 点击事件	
	local function ClockFunc()
		SoundManager:PlaySFX(SoundManager.Define.UIClick)
		local success, result = pcall(function()
			func(UIButton, button, param)
		end)

		if not success then
			warn("[Button] Error : ", button.Name, debug.traceback(result, 2))
		end
	end
	
	UIButton:CacheConnect(button, button.MouseButton1Click, "Click", ClockFunc)
	UIButton.ClickFuncCache[button] = ClockFunc

	-- 动画 & 提示
	self:HandleAnimation(button)
	UIButtonToolTip:Handle(button)
end

function UIButton:CacheConnect(button, signal, signalType, callback)
	local connection = signal:Connect(callback)
	local cacheInfo = UIButton.ConnectionCache[button]
	if not cacheInfo then
		cacheInfo = {
			Button = button,
			Connections = {}
		}
		
		UIButton.ConnectionCache[button] = cacheInfo
	end
	
	local signalDic = cacheInfo.Connections[signalType]
	if not signalDic then
		signalDic = {}
		cacheInfo.Connections[signalType] = signalDic
	end
	
	table.insert(signalDic , {
		Connection = connection,
		Function = callback,
	})
end

function UIButton:Click(button)
	local cacheInfo = UIButton.ConnectionCache[button]
	if not cacheInfo then return end
	cacheInfo.Connections["Click"][1].Function()
	cacheInfo.Connections["Down"][1].Function()
	task.delay(0.1, function()
		if not cacheInfo then return end
		local signalCache = cacheInfo.Connections["Up"]
		if signalCache then
			signalCache[1].Function()
		end
	end)	
end

function UIButton:Clear(button)
	if not button then return end
	local cacheInfo = UIButton.ConnectionCache[button]
	if cacheInfo then 
		for signalType, signalInfo in pairs(cacheInfo.Connections) do
			for _, connectionInfo in ipairs(signalInfo) do
				if connectionInfo.Connection.Connected then
					connectionInfo.Connection:Disconnect()
				end
			end	
			
			cacheInfo.Connections[signalType] = nil
		end
	end
	
	UIButton.ConnectionCache[button] = nil
	UIButton.SizeInfoCache[button] = nil
	UIButton.ClickFuncCache[button] = nil
end

-- 动画
local function MakeTween(button, size, duration)
	return TweenServiceManager.New(button)
		:To({ Size = size })
		:SetDuration(duration)
		:SetEase(Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
end

function UIButton:HandleAnimation(button)
	local hoverScale, clickScale, duration = 1.075, 0.925, 0.1

	local sizeInfo = UIButton.SizeInfoCache[button]
	if not sizeInfo then
		sizeInfo = {
			ScaleX = button.Size.X.Scale,
			ScaleY = button.Size.Y.Scale,
			OffsetX = button.Size.X.Offset,
			OffsetY = button.Size.Y.Offset,
		}
		
		UIButton.SizeInfoCache[button] = sizeInfo
	end

	local normalSize = UDim2.new(sizeInfo.ScaleX, sizeInfo.OffsetX, sizeInfo.ScaleY, sizeInfo.OffsetY)
	local hoverSize  = UDim2.new(sizeInfo.ScaleX * hoverScale, sizeInfo.OffsetX * hoverScale, sizeInfo.ScaleY * hoverScale, sizeInfo.OffsetY * hoverScale)
	local clickSize  = UDim2.new(sizeInfo.ScaleX * clickScale, sizeInfo.OffsetX * clickScale, sizeInfo.ScaleY * clickScale, sizeInfo.OffsetY * clickScale)

	local hoverTween = MakeTween(button, hoverSize, duration)
	local normalTween = MakeTween(button, normalSize, duration)
	local clickTween = MakeTween(button, clickSize, duration)

	local isHover = false
	UIButton:CacheConnect(button, button.MouseEnter, "Enter", function() 
		isHover = true
		hoverTween:Play() 
	end)
	UIButton:CacheConnect(button, button.MouseLeave, "Leave", function() 
		isHover = false
		normalTween:Play() 
	end)
	UIButton:CacheConnect(button, button.MouseButton1Down, "Down", function()
		clickTween:Play() 
	end)
	UIButton:CacheConnect(button, button.MouseButton1Up, "Up", function() 	
		if isHover then
			hoverTween:Play() 
		else
			normalTween:Play()
		end
	end)
	
	local icon = Util:GetChildByName(button, "Button_Icon")
	if icon then
		--UIIcon:HandleAnimation(button, icon)

		local tweenEnter = TweenServiceManager.New(icon)
			:To({ Rotation = 10 })
			:SetDuration(0.15)
			:SetEase(Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local tweenLeave = TweenServiceManager.New(icon)
			:To({ Rotation = 0 })
			:SetDuration(0.15)
			:SetEase(Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		UIButton:CacheConnect(button, button.MouseEnter, "Enter", function() 
			tweenEnter:Play()
		end)
		
		UIButton:CacheConnect(button, button.MouseLeave, "Leave", function() 
			tweenLeave:Play()
		end)
	end
end

return UIButton
