local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local TweenServiceManager = require(game.ReplicatedStorage.ScriptAlias.TweenServiceManager)
local SoundManager = require(game.ReplicatedStorage.ScriptAlias.SoundManager)
local UIButtonToolTip = require(game.ReplicatedStorage.ScriptAlias.UIButtonTooltip)

local UIButton = {}

local table_insert = table.insert
local UDim2_new = UDim2.new

UIButton.ConnectionCache = setmetatable({}, { __mode = "k" })
UIButton.SizeInfoCache = setmetatable({}, { __mode = "k" })
UIButton.ClickFuncCache = setmetatable({}, { __mode = "k" })

----------------------------------------------------------------------------------
-- Connection

function UIButton:CacheConnect(button, signal, callback)
	local connection = signal:Connect(callback)

	local list = UIButton.ConnectionCache[button]
	if not list then
		list = {}
		UIButton.ConnectionCache[button] = list
	end

	table_insert(list, connection)
end

function UIButton:Clear(button)
	local list = UIButton.ConnectionCache[button]
	if list then
		for i = 1, #list do
			local conn = list[i]
			if conn and conn.Connected then
				conn:Disconnect()
			end
		end
	end

	UIButton.ConnectionCache[button] = nil
	UIButton.SizeInfoCache[button] = nil
	UIButton.ClickFuncCache[button] = nil
end

----------------------------------------------------------------------------------
-- Handle Click

function UIButton:Handle(button, func, param)
	if not button or not button:IsA("GuiButton") then return end
	if typeof(func) ~= "function" then return end

	self:Clear(button)

	local function ClickFunc()
		SoundManager:PlaySFX(SoundManager.Define.UIClick)
		local success, err = pcall(func, UIButton, button, param)
		if not success then
			warn("[UIButton Error]", button.Name, err)
		end
	end

	UIButton.ClickFuncCache[button] = ClickFunc
	self:CacheConnect(button, button.MouseButton1Click, ClickFunc)

	self:HandleAnimation(button)
	UIButtonToolTip:Handle(button)
end

function UIButton:Click(button)
	local func = UIButton.ClickFuncCache[button]
	if func then
		func()
	end
end

----------------------------------------------------------------------------------
-- Tween

local function CreateTween(target, props, duration)
	return TweenServiceManager.New(target)
		:To(props)
		:SetDuration(duration)
		:SetEase(Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
end

----------------------------------------------------------------------------------
-- Animation

function UIButton:HandleAnimation(button)
	local hoverScale = 1.075
	local clickScale = 0.925
	local duration = 0.1

	-- Cache Size
	local sizeInfo = UIButton.SizeInfoCache[button]
	if not sizeInfo then
		local sx, sy = button.Size.X.Scale, button.Size.Y.Scale
		local ox, oy = button.Size.X.Offset, button.Size.Y.Offset

		sizeInfo = {
			Normal = UDim2_new(sx, ox, sy, oy),
			Hover  = UDim2_new(sx * hoverScale, ox * hoverScale, sy * hoverScale, oy * hoverScale),
			Click  = UDim2_new(sx * clickScale, ox * clickScale, sy * clickScale, oy * clickScale),
		}

		UIButton.SizeInfoCache[button] = sizeInfo
	end

	-- 单Tween复用
	local currentTween
	local function PlaySizeTween(size)
		if currentTween then
			currentTween:Stop()
		end
		
		currentTween = CreateTween(button, { Size = size }, duration)
		currentTween:Play()
	end

	-- Icon
	local icon = Util:GetChildByName(button, "Button_Icon")
	if not icon then
		icon = Util:GetChildByName(button, "Image_Icon")
	end
	
	local iconTween

	local function PlayIcon(rotation)
		if not icon then return end
		if iconTween then
			iconTween:Stop()
		end
		
		iconTween = CreateTween(icon, { Rotation = rotation }, 0.15)
		iconTween:Play()
	end

	local isHover = false

	-- Enter
	self:CacheConnect(button, button.MouseEnter, function()
		isHover = true
		PlaySizeTween(sizeInfo.Hover)
		PlayIcon(10)
	end)

	-- Leave
	self:CacheConnect(button, button.MouseLeave, function()
		isHover = false
		PlaySizeTween(sizeInfo.Normal)
		PlayIcon(0)
	end)

	-- Down
	self:CacheConnect(button, button.MouseButton1Down, function()
		PlaySizeTween(sizeInfo.Click)
	end)

	-- Up
	self:CacheConnect(button, button.MouseButton1Up, function()
		if isHover then
			PlaySizeTween(sizeInfo.Hover)
		else
			PlaySizeTween(sizeInfo.Normal)
		end
	end)
end

return UIButton