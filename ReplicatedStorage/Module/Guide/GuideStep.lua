local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local BuildingManager = require(game.ReplicatedStorage.ScriptAlias.BuildingManager)
local ResourcesManager = require(game.ReplicatedStorage.ScriptAlias.ResourcesManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)

local GuideDefine = require(game.ReplicatedStorage.ScriptAlias.GuideDefine)

local GuideStep = {}
GuideStep.__index = GuideStep

function GuideStep.new(key, config, info)
	local self = setmetatable({}, GuideStep)
	self.Key = key
	self.Config = config
	self.Info = info
	self.IsInit = false
	if config.TargetMode == GuideDefine.TargetMode.Building then
		self.TargetBuilding = BuildingManager:GetBuilding(config.TargetBuilding)
		self.TargetPos = self.TargetBuilding.BuildingPart:GetPivot().Position
	elseif config.TargetMode == GuideDefine.TargetMode.Pos then
		self.TargetPos = config.TargetPos
	end
	
	self:Init()
	self.IsInit = true
	
	return self
end

function GuideStep:Init()
	self:InitImpl()
	
	--warn("Guide Init", self.Key)
end

function GuideStep:Update(deltaTime)
	if not self.IsInit then return end
	if self.Config.TargetMode ~= GuideDefine.TargetMode.None and self.Arrow then
		local player = game.Players.LocalPlayer
		if not player then return end	
		local startPos = PlayerManager:GetPosition(player)
		if not startPos then return end
		
		local endPos = self.TargetPos
		if not endPos then return end
		
		startPos = Vector3.new(startPos.X, GuideDefine.ArrowHeight, startPos.Z)
		endPos = Vector3.new(endPos.X, GuideDefine.ArrowHeight, endPos.Z)
		
		local parentCFrame = self.Arrow.CFrame
		local startWorldCFrame = CFrame.new(startPos)
		self.Arrow.Start.CFrame = parentCFrame:Inverse() * startWorldCFrame
		local endWorldCFrame = CFrame.new(endPos)
		self.Arrow.End.CFrame = parentCFrame:Inverse() * endWorldCFrame
	end
end

function GuideStep:Enable()
	self:SetPart(true)
	self:SetUI(true)
	self:SetTip(true)
	if self.Config.TargetMode ~= GuideDefine.TargetMode.None then
		self:SetArrow(true)
	end
	
	self.UpdateHandle = UpdatorManager:RenderStepped(function(deltaTime)
		self:Update(deltaTime)
	end)
	
	self:EnableImpl()
	
	--warn("Guide Start", self.Key)
end

function GuideStep:Disable()
	self:SetPart(false)
	self:SetUI(false)
	self:SetTip(false)
	if self.Config.TargetMode ~= GuideDefine.TargetMode.None then
		self:SetArrow(false)
	end
	
	if self.UpdateHandle then
		self.UpdateHandle:Destroy()
		self.UpdateHandle = nil
	end
	
	self:DisableImpl()
	
	--warn("Guide End", self.Key)
end

function GuideStep:SetTip(active)
	local page = UIManager:GetPage("UIMain")
	local root = page.MainFrame
	local uiGuide = Util:GetChildByName(root, "GuideFrame", true)
	local info = nil
	if active then
		 info = {
			GuideTip = self.Config.TipText
		}
	else
		info = {
			GuideTip = ""
		}
	end
	
	UIInfo:SetInfo(uiGuide, info)
end

function GuideStep:SetArrow(active)
	if active then
		local arrowPrefab = ResourcesManager:Load(GuideDefine.ArrowPrefab)
		self.Arrow = arrowPrefab:Clone()
		self.Arrow.Parent = game.Workspace
	else
		if self.Arrow then
			self.Arrow:Destroy()
			self.Arrow = nil
		end
	end
end

function GuideStep:SetPart(active)
	local config = self.Config
	if not config.ShowPartList then return end
	for _, partPath in ipairs(config.ShowPartList) do
		local part = ResourcesManager:GetPartByPath(partPath)
		if part then
			if active then
				Util:ActiveObject(part)
			else
				Util:DeActiveObject(part)
			end
		else
			warn("[Guide] Part not found :", partPath)
		end
	end
end

function GuideStep:SetUI(active)
	local config = self.Config
	if not config.ShowUIList then return end
	for _, uiPath in ipairs(config.ShowUIList) do
		local ui = ResourcesManager:GetGuiByPath(uiPath)
		if ui then
			if active then
				ui.Visible = true
			else
				ui.Visible = false
			end
		else
			warn("[Guide] UI not found :", uiPath)
		end
	end
end

function GuideStep:Check()
	local check = self:CheckImpl()
	return check
end

function GuideStep:Complete()
	local guideManager = require(game.ReplicatedStorage.ScriptAlias.GuideManager)
	guideManager:Complete(self.Key)
	
	--print("Complete", self.Key)
end

-----------------------------------------------------------------------------------------
-- Impl

function GuideStep:InitImpl()

end

function GuideStep:EnableImpl()

end

function GuideStep:DisableImpl()

end

function GuideStep:CheckImpl()
	return false
end

return GuideStep
