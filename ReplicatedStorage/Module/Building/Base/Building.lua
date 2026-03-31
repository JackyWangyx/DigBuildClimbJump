local SceneManager = require(game.ReplicatedStorage.ScriptAlias.SceneManager)
local SceneAreaManager = require(game.ReplicatedStorage.ScriptAlias.SceneAreaManager)
local TriggerArea = require(game.ReplicatedStorage.ScriptAlias.TriggerArea)
local TriggerAreaOpenUI = require(game.ReplicatedStorage.ScriptAlias.TriggerAreaOpenUI)
local ProximityArea = require(game.ReplicatedStorage.ScriptAlias.ProximityArea)
local ProximityAreaOpenUI = require(game.ReplicatedStorage.ScriptAlias.ProximityAreaOpenUI)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local Building = {}

Building.__index = Building

Building.Mode = {
	Global = 1,
	Area = 2,
}

Building.TriggerMode = {
	None = 0,
	Trigger = 1,
	Proximity = 2,
	TriggerOpenUI = 3,
	ProximityOpenUI = 4,
}

----------------------------------------------------------------------------------------------
-- New

local function new(buildingPart, opts, triggerMode)
	local self = setmetatable({}, Building)
	self.Player = game.Players.LocalPlayer
	self.BuildingPart = buildingPart
	self.TriggerPart = buildingPart:FindFirstChild("Trigger")
	--self.RendererTrans = buildingPart:FindFirstChild("Renderer")
	--self.ThemeKey = "Default"
	self.OnlySelf = true
	self.TriggerMode = triggerMode or Building.TriggerMode.None
	self.Options = opts
	self.CurrentAreaIndex = SceneAreaManager.CurrentAreaIndex
	self.IsSelfArea = true
	
	if opts.Mode == Building.Mode.Global then
		self.IsSelfArea = true
	else
		self.IsSelfArea = SceneAreaManager.CurrentAreaIndex == opts.AreaIndex
	end
	
	--print(buildingPart.Name, self.IsSelfArea, opts.AreaIndex)
	
	return self
end

function Building:CheckEnable()
	if self.Options.Mode == Building.Mode.Global then
		return true
	else
		return self.IsSelfArea
	end
end

----------------------------------------------------------------------------------------------
-- Normal

function Building.Normal(buildingPart, opts)
	local self = new(buildingPart, opts, Building.TriggerMode.None)
	if not self:CheckEnable() then return self end
	self:Refresh()	
	return self
end

----------------------------------------------------------------------------------------------
-- Trigger

function Building.Trigger(buildingPart, opts, enterFunc, exitFunc, onlySelf)
	local self = new(buildingPart, opts, Building.TriggerMode.Trigger)
	if onlySelf == nil then
		onlySelf = true
	end

	self.EnterFunc = enterFunc
	self.ExitFunc = exitFunc
	self.OnlySelf = onlySelf
	
	if not self:CheckEnable() then return self end
	
	TriggerArea:Handle(self.TriggerPart, function()
		if self.EnterFunc then
			self.EnterFunc(self)
		end
	end, function()
		if self.ExitFunc then
			self.ExitFunc(self)
		end
	end, self.OnlySelf)
	
	self:Refresh()
	return self
end

function Building.TriggerOpenUI(buildingPart, opts, uiName, uiParam)
	local self = new(buildingPart, opts, Building.TriggerMode.TriggerOpenUI)
	
	self.UIName = uiName
	self.UIParam = uiParam
	
	if not self:CheckEnable() then return self end
	
	TriggerAreaOpenUI:Handle(self.TriggerPart, self.UIName, self.UIParam)
	
	self:Refresh()
	return self
end

----------------------------------------------------------------------------------------------
-- Proximity

function Building.Proximity(buildingPart, opts, tipText, triggerFunc)
	local self = new(buildingPart, opts, Building.TriggerMode.Proximity)
	
	self.TipText = tipText
	self.TriggerFunc = triggerFunc
	
	ProximityArea:Handle(self.TriggerPart, self.TipText, function()
		if not self:CheckEnable() then return end
		if self.TriggerFunc then
			self.TriggerFunc(self)
		end
	end)
	
	self:Refresh()
	return self
end

function Building.ProximityOpenUI(buildingPart, opts, tipText, uiName, uiParam)
	local self = new(buildingPart, opts, Building.TriggerMode.ProximityOpenUI)
	
	self.TipText = tipText
	self.UIName = uiName
	self.UIParam = uiParam
	
	if not self:CheckEnable() then return self end
	
	ProximityAreaOpenUI:Handle(self.TriggerPart, self.TipText, self.UIName, self.UIParam)
	
	self:Refresh()
	return self
end

----------------------------------------------------------------------------------------------
-- Refresh

function Building:Refresh()
	if self.RefreshFunc then
		self.RefreshFunc()
	end
end

return Building
