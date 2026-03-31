local RunService = game:GetService("RunService")

local MouseUtil = {}

MouseUtil.Target = nil

MouseUtil.EventType = {
	Hover = 1,
	Button1Down = 2,
	Button1Up = 3,
	Button2Down = 4,
	Button2Up = 5,
	Enter = 6,
	Leave = 7,
	Move = 8,
	HighLight = 9
}

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

RunService.RenderStepped:Connect(function()
	MouseUtil.Target = mouse.Target
	MouseUtil:HandleHighLight()
	MouseUtil:HandleHover()
end)

local MouseEventCache = {}

mouse.Button1Down:Connect(function()
	MouseUtil:HandleButton1Down()
end)

mouse.Button1Up:Connect(function()
	MouseUtil:HandleButton1Up()
end)

mouse.Button2Down:Connect(function()
	MouseUtil:HandleButton2Down()
end)

mouse.Button2Up:Connect(function()
	MouseUtil:HandleButton2Up()
end)

function MouseUtil:GetEventCache(part, eventType)
	if not part then return nil end
	local partCache = MouseEventCache[part]
	if not partCache then
		partCache = {}
		MouseEventCache[part] = partCache
	end
	
	local eventCache = partCache[eventType]
	if not eventCache then
		eventCache = {}
		partCache[eventType] = eventCache
	end
	
	return eventCache
end

function MouseUtil:Register(part, eventType, func)
	if not part then return end
	local eventCache = MouseUtil:GetEventCache(part, eventType)
	table.insert(eventCache, func)
end

function MouseUtil:UnRegister(part, eventType, func)
	if not part then return end
	local partCache = MouseEventCache[part]
	if not partCache then return end

	local eventCache = partCache[eventType]
	if not eventCache then return end

	if func then
		for i = #eventCache, 1, -1 do
			if eventCache[i] == func then
				table.remove(eventCache, i)
			end
		end
	else
		partCache[eventType] = nil
	end

	if next(partCache) == nil then
		MouseEventCache[part] = nil
	end
end

function MouseUtil:UnRegisterAll(part, eventType)
	local partCache = MouseEventCache[part]
	if partCache then
		partCache[eventType] = nil
		if next(partCache) == nil then
			MouseEventCache[part] = nil
		end
	end
end

function MouseUtil:CallEvent(part, eventType, ...)
	local eventCacne = MouseUtil:GetEventCache(part, eventType)
	for _, event in pairs(eventCacne) do
		if not event then continue end
		local success, err = pcall(event, ...)
		if not success then
			warn("[MouseUtil Error]", debug.traceback(err, 2))
		end
	end
end

-- Button1
function MouseUtil:HandleButton1Down()
	if MouseUtil.Target then
		MouseUtil:CallEvent(MouseUtil.Target, MouseUtil.EventType.Button1Down)
	end
end

function MouseUtil:HandleButton1Up()
	if MouseUtil.Target then
		MouseUtil:CallEvent(MouseUtil.Target, MouseUtil.EventType.Button1Up)
	end
end

-- Button2
function MouseUtil:HandleButton2Down()
	if MouseUtil.Target then
		MouseUtil:CallEvent(MouseUtil.Target, MouseUtil.EventType.Button2Down)
	end
end

function MouseUtil:HandleButton2Up()
	if MouseUtil.Target then
		MouseUtil:CallEvent(MouseUtil.Target, MouseUtil.EventType.Button2Up)
	end
end

-- Hover
local CurrentHoverTarget = nil

function MouseUtil:HandleHover()
	local target = MouseUtil.Target
	if target ~= CurrentHoverTarget then
		if CurrentHoverTarget then
			if #MouseUtil:GetEventCache(CurrentHoverTarget, MouseUtil.EventType.Leave) > 0 then
				MouseUtil:CallEvent(CurrentHoverTarget, MouseUtil.EventType.Leave, CurrentHoverTarget)
			end
		end
		if target then
			if #MouseUtil:GetEventCache(target, MouseUtil.EventType.Enter) > 0 then
				MouseUtil:CallEvent(target, MouseUtil.EventType.Enter, target)
			end
		end

		CurrentHoverTarget = target
	else
		if target and #MouseUtil:GetEventCache(target, MouseUtil.EventType.Move) > 0 then
			MouseUtil:CallEvent(target, MouseUtil.EventType.Move, target)
		end
	end
end

-- HighLight
local HighLightSelectionBox = Instance.new("SelectionBox")
HighLightSelectionBox.LineThickness = 0.05
HighLightSelectionBox.Color3 = Color3.fromRGB(185, 0, 105)
HighLightSelectionBox.SurfaceTransparency = 1
HighLightSelectionBox.Visible = false
HighLightSelectionBox.Parent = game.Workspace

local CurrentSelectionTarget = nil

function MouseUtil:HandleHighLight()
	local target = MouseUtil.Target
	if target ~= CurrentSelectionTarget then
		if CurrentSelectionTarget then
			HighLightSelectionBox.Adornee = nil
			HighLightSelectionBox.Visible = false
			MouseUtil:CallEvent(CurrentSelectionTarget, MouseUtil.EventType.HighLight, false)
		end

		if target and #MouseUtil:GetEventCache(target, MouseUtil.EventType.HighLight) > 0 then
			CurrentSelectionTarget = target
			HighLightSelectionBox.Adornee = target
			HighLightSelectionBox.Visible = true
			MouseUtil:CallEvent(target, MouseUtil.EventType.HighLight, true)
		else
			CurrentSelectionTarget = nil
		end
	end
end

return MouseUtil
