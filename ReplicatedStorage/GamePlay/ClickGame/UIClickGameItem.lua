local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local ClickGameEffect = require(script.Parent.ClickGameEffect)
local ClickGameDefine = require(script.Parent.ClickGameDefine)
local ClickFx = require(script.Parent.ClickFx)

local UIClickGameItem = {}
UIClickGameItem.__index = UIClickGameItem

function UIClickGameItem.New(initParam)
	local self = setmetatable({
		Part = initParam.Part,
		Parent = initParam.Parent,
		Button = initParam.Button,
		Duration = initParam.Duration,
		IsAutoClick = initParam.IsAutoClick,
		Timer = 0,
		Progress = 0,
		LastClickTime = 0,
		OnSpawn = initParam.OnSpawn,
		OnClick = initParam.OnClick,
		OnUpdate = initParam.OnUpdate,
		OnDeSpawn = initParam.OnDeSpawn,
	}, UIClickGameItem)

	self.Part.Parent = self.Parent
	UIButton:Handle(self.Button, function()
		self.LastClickTime = tick()
		if not self.IsAutoClick then
			ClickFx:SpawnFx()
		end	
		self.OnClick(self)
	end)

	self.Part.Position = ClickGameEffect:GetRandomPos(self.Parent, ClickGameDefine.Game.ContainerWidth, ClickGameDefine.Game.ContainerHeight)
	ClickGameEffect:EffectRandMove(self)
	ClickGameEffect:EffectLifeTimeScale(self)

	self.OnSpawn(self)
	return self
end

function UIClickGameItem:DeSpawn()
	if self.OnDeSpawn then
		self.OnDeSpawn(self)
	end

	UIButton:Clear(self.Button)
	self.Part:Destroy()
end

local function getScreenPosition(guiObject, returnCenter)
	returnCenter = returnCenter == nil or returnCenter
	local pos = guiObject.AbsolutePosition
	if guiObject.Parent and guiObject.Parent:IsA("ScreenGui") then
		return returnCenter and (pos + guiObject.AbsoluteSize / 2) or pos
	else
		return returnCenter and (pos + guiObject.AbsoluteSize / 2) or pos
	end
end

function UIClickGameItem:AutoClick()
	UIButton:Click(self.Button)
	local pos = getScreenPosition(self.Button)
	ClickFx:SpawnFxOnPos(pos)
end

function UIClickGameItem:Update(deltaTime)
	self.Timer += deltaTime
	self.Progress = self.Timer / self.Duration
	if self.Progress > 1 then self.Progress = 1 end

	self.OnUpdate(self, deltaTime)
	if self.Timer >= self.Duration then
		self:DeSpawn()
	end
end

return UIClickGameItem
