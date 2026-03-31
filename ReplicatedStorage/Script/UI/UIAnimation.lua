local UTween = require(game.ReplicatedStorage.ScriptAlias.UTween)

local UIAnimation = {}

local UI_ANIMATION_DURATION = 0.25

function UIAnimation:HandlePageShow(uiInfo, animationType)
	animationType = animationType or "Default"
	uiInfo.ShowTweener = {}
	uiInfo.ShowAnimationType = animationType
	local mainFrame = uiInfo.MainFrame
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	if animationType == "None" then
		
	elseif animationType == "Default" then
		table.insert(uiInfo.ShowTweener, UTween:GuiScaleValue(mainFrame, Vector2.new(0,0), Vector2.new(1,1), UI_ANIMATION_DURATION)
			:SetEase(UTween.EaseType.OutBack)
			:SetOnComplete(function()
				uiInfo.UI.Enabled = true
			end))
		table.insert(uiInfo.ShowTweener, UTween:GuiPositionValue(mainFrame, Vector2.new(0.5, 1.5), Vector2.new(0.5, 0.5), UI_ANIMATION_DURATION)
			:SetEase(UTween.EaseType.OutQuart))
		table.insert(uiInfo.ShowTweener, UTween:GuiGroupTransparency(uiInfo.UI, 1, 0, UI_ANIMATION_DURATION)
			:SetEase(UTween.EaseType.InOutSine))
		
	elseif animationType == "Scale" then
		table.insert(uiInfo.ShowTweener, UTween:GuiScaleValue(mainFrame, Vector2.new(0,0), Vector2.new(1,1), UI_ANIMATION_DURATION)
			:SetEase(UTween.EaseType.OutBack)
			:SetOnComplete(function()
				uiInfo.UI.Enabled = true
			end))
		
	elseif animationType == "Fade" then
		table.insert(uiInfo.ShowTweener, UTween:GuiGroupTransparency(uiInfo.UI, 1, 0, UI_ANIMATION_DURATION)
			:SetEase(UTween.EaseType.InOutSine)
			:SetOnComplete(function()
				uiInfo.UI.Enabled = true
			end))
		
	elseif animationType == "Slide" then
		table.insert(uiInfo.ShowTweener, UTween:GuiPositionValue(mainFrame, Vector2.new(0.5, 1.5), Vector2.new(0.5, 0.5), UI_ANIMATION_DURATION)
			:SetEase(UTween.EaseType.OutQuart)
			:SetOnComplete(function()
				uiInfo.UI.Enabled = true
			end))
		
	else
		warn("[UIAnimation] Show not found : ", uiInfo.Name)
	end
	
	for _, tweener in ipairs(uiInfo.ShowTweener) do
		tweener:SetAutoDeSpawn(false)
	end
end

function UIAnimation:HandlePageHide(uiInfo, animationType)
	animationType = animationType or "Default"
	uiInfo.HideTweener = {}
	uiInfo.HideAnimationType = animationType
	local mainFrame = uiInfo.MainFrame
	if animationType == "None" then
		
	elseif animationType == "Default" then
		table.insert(uiInfo.HideTweener, UTween:GuiScaleValue(mainFrame, Vector2.new(1,1), Vector2.new(0,0), UI_ANIMATION_DURATION)
			:SetEase(UTween.EaseType.InBack)
			:SetOnComplete(function()
				uiInfo.UI.Enabled = false
			end))
		--table.insert(uiInfo.HideTweener, UTween:GuiPositionValue(mainFrame, Vector2.new(0.5, 0.5), Vector2.new(0.5, 1.5), UI_ANIMATION_DURATION)
		--	:SetEase(UTween.EaseType.InQuart))
		table.insert(uiInfo.HideTweener, UTween:GuiGroupTransparency(uiInfo.UI, 0, 1, UI_ANIMATION_DURATION)
			:SetEase(UTween.EaseType.InOutSine))
		
	elseif animationType == "Scale" then
		table.insert(uiInfo.HideTweener, UTween:GuiScaleValue(mainFrame, Vector2.new(1,1), Vector2.new(0,0), UI_ANIMATION_DURATION)
			:SetEase(UTween.EaseType.InBack)
			:SetOnComplete(function()
				uiInfo.UI.Enabled = false
			end))
		
	elseif animationType == "Fade" then
		table.insert(uiInfo.HideTweener, UTween:GuiGroupTransparency(uiInfo.UI, 0, 1, UI_ANIMATION_DURATION)
			:SetEase(UTween.EaseType.InOutSine)
			:SetOnComplete(function()
				uiInfo.UI.Enabled = false
			end))
		
	elseif animationType == "Slide" then
		table.insert(uiInfo.HideTweener, UTween:GuiPositionValue(mainFrame, Vector2.new(0.5, 0.5), Vector2.new(0.5, -1.5), UI_ANIMATION_DURATION)
			:SetEase(UTween.EaseType.InQuart)
			:SetOnComplete(function()
				uiInfo.UI.Enabled = false
			end))
		
	else
		warn("[UIAnimation] Hide not found : ", uiInfo.Name)
	end
	
	for _, tweener in ipairs(uiInfo.HideTweener) do
		tweener:SetAutoDeSpawn(false)
	end
end

-- Dialog

function UIAnimation:ShowDialog(mainFrame)
	UTween:GuiScaleValue(mainFrame, Vector2.new(0,0), Vector2.new(1,1), UI_ANIMATION_DURATION)
		:SetEase(UTween.EaseType.OutBack)
end

function UIAnimation:HideDialog(mainFrame, callback)
	UTween:GuiScaleValue(mainFrame, Vector2.new(1,1), Vector2.new(0,0), UI_ANIMATION_DURATION)
		:SetEase(UTween.EaseType.InBack)
		:SetOnComplete(function()
			callback()
		end)
end

-- Blur Fade

local UIBlurBackground = nil
local IsBlurShown = false

function UIAnimation:GetBlur()
	if not UIBlurBackground then
		local blur = Instance.new("BlurEffect")
		blur.Size = 0
		blur.Name = "UIBlur"
		blur.Parent = game.Lighting
		UIBlurBackground = blur
	end
	
	return UIBlurBackground
end

function UIAnimation:RefreshBlur(uiManager)
	--local pageGroup = uiManager:GetGroup(uiManager.GroupType.Page)
	--local coverGroup = uiManager:GetGroup(uiManager.GroupType.Cover)
	--local topGroup = uiManager:GetGroup(uiManager.GroupType.Top)
	
	--local needShow = pageGroup.Stack:Count() > 1 or topGroup.Stack:Count() > 0
	--if needShow then
	--	UIAnimation:BlurFadeIn()
	--else
	--	UIAnimation:BlurFadeOut()
	--end
end

function UIAnimation:BlurFadeIn()
	if IsBlurShown then return end
	local blur = UIAnimation:GetBlur()
	UTween:Value(0, 35, UI_ANIMATION_DURATION, function(value)
		blur.Size = value
	end)
		:SetOnComplete(function()
			IsBlurShown = true
		end)
	UTween:CameraFOV(game.Workspace.CurrentCamera, 70, 75, UI_ANIMATION_DURATION)
		:SetEase(UTween.EaseType.InSine)
end

function UIAnimation:BlurFadeOut()
	if not IsBlurShown then return end
	local blur = UIAnimation:GetBlur()
	UTween:Value(35, 0, UI_ANIMATION_DURATION, function(value)
		blur.Size = value
	end)
		:SetOnComplete(function()
			IsBlurShown = false
		end)
	UTween:CameraFOV(game.Workspace.CurrentCamera, 75, 70, UI_ANIMATION_DURATION)
		:SetEase(UTween.EaseType.OutSine)
end

return UIAnimation
