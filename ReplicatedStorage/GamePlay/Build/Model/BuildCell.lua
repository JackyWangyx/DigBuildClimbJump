local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local MouseUtil = require(game.ReplicatedStorage.ScriptAlias.MouseUtil)
local HighlightUtil = require(game.ReplicatedStorage.ScriptAlias.HighlightUtil)

local BuildUtil = require(game.ReplicatedStorage.ScriptAlias.BuildUtil)
local BuildDefine = require(game.ReplicatedStorage.ScriptAlias.BuildDefine)

local BuildCell = {}

BuildCell.__index = BuildCell

BuildCell.BuildManager = nil
BuildCell.CellInfo = nil

function BuildCell.new(manager, cellInfo)
	local self = setmetatable({
		BuildManager = manager,
		CellInfo = cellInfo,
	}, BuildCell)
	
	self:Init()
	return self
end

function BuildCell:Init()
	local cellInfo = self.CellInfo
	local cellPart = cellInfo.Part	
	MouseUtil:Register(cellPart, MouseUtil.EventType.Move, function(isSelect)
		if self.BuildManager.CurrentPart then
			local position = cellPart.Position
			BuildUtil:SetPartPosition(self.BuildManager.CurrentPart, position)
		end
	end)
	
	MouseUtil:Register(cellPart, MouseUtil.EventType.Button1Down, function()
		if self.BuildManager.Phase == BuildDefine.BuildPhase.Edit then
			self.BuildManager:SetPart(cellInfo.X, cellInfo.Y, cellInfo.Z)
		elseif self.BuildManager.Phase == BuildDefine.BuildPhase.Remove then
			self.BuildManager:RemovePart(cellInfo.X, cellInfo.Y, cellInfo.Z)
		end
	end)
	
	MouseUtil:Register(cellPart, MouseUtil.EventType.Enter, function()
		local info = self.CellInfo
		local model = self.BuildManager.BuildModel
		if not model then return end
		
		if self.BuildManager.Phase == BuildDefine.BuildPhase.Edit then
			HighlightUtil:EnableSelectionBox(cellPart, BuildDefine.SetTipColor)
		elseif self.BuildManager.Phase == BuildDefine.BuildPhase.Remove then	
			local part = model:GetPart(info.X, info.Y, info.Z)
			if not part then return end
			HighlightUtil:EnableHighlight(part, BuildDefine.RemoveTipColor)
		end
	end)
	
	MouseUtil:Register(cellPart, MouseUtil.EventType.Leave, function()
		local info = self.CellInfo
		local model = self.BuildManager.BuildModel
		if not model then return end
		
		if self.BuildManager.Phase == BuildDefine.BuildPhase.Edit then
			HighlightUtil:DisableSelectionBox(cellPart)
		elseif self.BuildManager.Phase == BuildDefine.BuildPhase.Remove then
			local part = model:GetPart(info.X, info.Y, info.Z)
			if not part then return end
			HighlightUtil:DisableHighlight(part)
		end
	end)
end

function BuildCell:Enable()
	local cellPart = self.CellInfo.Part	
	cellPart.Parent = self.CellInfo.Parent	
end

function BuildCell:Disable()
	local cellPart = self.CellInfo.Part	
	cellPart.Parent = nil
end

return BuildCell