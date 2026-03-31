local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local SceneManager = require(game.ReplicatedStorage.ScriptAlias.SceneManager)

local PlaeyrStatus = require(game.ServerScriptService.ScriptAlias.PlayerStatus)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)
local AnimalRequest = require(game.ServerScriptService.ScriptAlias.Animal)
local ToolRequest = require(game.ServerScriptService.ScriptAlias.Tool)


local Define = require(game.ReplicatedStorage.Define)

local AnimalServerHandler = {}
local MaxRotate = 45
local FrontDistance = 0
local PaddingX = 5
local PaddingY = 15
local PlayerInfoDic = {}

function AnimalServerHandler:Init()
	PlayerManager:HandleCharacterAddRemove(function(player, character)
	end, function(player, character)
		AnimalServerHandler:Clear(player)
	end)

	EventManager:Listen(EventManager.Define.RefreshAnimal, function(player)
		AnimalServerHandler:Refresh(player)
	end)

	UpdatorManager:Heartbeat(function(deltaTime)
		AnimalServerHandler:Update(deltaTime)
	end)
end

function AnimalServerHandler:GetPlayerInputX(player)
	if not player then return 0 end
	local humanoid = PlayerManager:GetHumanoid(player)
	local rootPart = PlayerManager:GetHumanoidRootPart(player)
	if humanoid == nil or rootPart == nil then return 0 end
	local moveDirection = humanoid.MoveDirection
	local playerCFrame = rootPart.CFrame
	local rightVector = playerCFrame.RightVector
	local xAxisInput = moveDirection:Dot(rightVector)
	xAxisInput = math.clamp(xAxisInput, -1, 1)
	return xAxisInput
end

--[[
function AnimalServerHandler:GetAnimalPos(count, index)
	if index < 1 or index > count then
		return Vector3.zero
	end
	local cols = math.ceil(math.sqrt(count))
	local rows = math.ceil(count / cols)
	local row = math.floor((index - 1) / cols)
	local col = (index - 1) % cols
	local z = FrontDistance + row * PaddingY + (rows / 2 * PaddingY)
	local width = (cols - 1) * PaddingX
	local x = col * PaddingX - width / 2
	local y = 0
	return Vector3.new(x, y, z)
end
--]]

-- 修改后的宠物位置分布函数
function AnimalServerHandler:GetAnimalPos(count, index)
	if index < 1 or index > count then
		return {pos = Vector3.new(0, 0, 0), row = 0}
	end

	local rowCols = {}
	-- 手动定义 1~8 的分布模式
	if count == 1 then
		rowCols = {1}
	elseif count == 2 then
		rowCols = {2}
	elseif count == 3 then
		rowCols = {2, 1}
	elseif count == 4 then
		rowCols = {2, 2}
	elseif count == 5 then
		rowCols = {3, 2}
	elseif count == 6 then
		rowCols = {3, 3}
	elseif count == 7 then
		rowCols = {4, 3}
	elseif count == 8 then
		rowCols = {4, 4}
	else
		local maxCols = 4
		local left = count
		while left > 0 do
			local cols = math.min(maxCols, left)
			table.insert(rowCols, cols)
			left = left - cols
		end
	end

	-- 找出当前排
	local remaining = index
	local row = 1
	for i, cols in ipairs(rowCols) do
		if remaining <= cols then
			row = i
			break
		else
			remaining = remaining - cols
		end
	end

	local col = remaining
	local currentRowCount = rowCols[row]
	local rowWidth = (currentRowCount - 1) * PaddingX

	-- X 轴居中
	local x = (col - 1) * PaddingX - rowWidth / 2

	-- Z 轴按排数，但第一排固定
	local z
	if row == 1 then
		z = FrontDistance
	else
		z = FrontDistance + (row - 1) * PaddingY
	end

	local y = 0
	local pos = Vector3.new(x, y, z)
	return {Pos = pos, Row = row}
end

function AnimalServerHandler:Refresh(player)
	AnimalServerHandler:Clear(player)
	AnimalServerHandler:Create(player)
end

function AnimalServerHandler:Create(player)
	local playerInfo = PlayerInfoDic[player.UserId]
	if playerInfo then
		AnimalServerHandler:Clear(player)
	end

	local toolServerHandler = require(game.ServerScriptService.ScriptAlias.ToolServerHandler)
	local car = toolServerHandler:GetTool(player)
	if not car then
		return
	end

	local folder = car:FindFirstChild("Animal")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Animal"
		folder.Parent = car
	end

	local equipList = AnimalRequest:GetEquipList(player)
	local count = #equipList
	local cols = math.ceil(math.sqrt(count))
	local rows = math.ceil(count / cols)
	local animalPoint = Util:GetChildByName(car, "AnimalPoint")

	playerInfo = {
		Player = player,
		RootPart = PlayerManager:GetHumanoidRootPart(player),
		IsGaming = false,
		IsTraining = false,
		Car = car,
		Folder = folder,
		Row = rows,
		Col = cols,
		AnimalPoint = animalPoint,
		AnimalList = {}
	}
	
	playerInfo.LastPos = playerInfo.RootPart.Position

	for index = 1, count do
		local equipAnimalInfo = equipList[index]
		local animalData = ConfigManager:GetData("Animal", equipAnimalInfo.ID)
		local animalPrefab = Util:LoadPrefab(animalData.Prefab)
		local animal = animalPrefab:Clone()
		animal.Parent = folder
		animal.Name = "Animal_" .. tostring(index) .. "_" .. equipAnimalInfo.InstanceID
		local offset = Vector3.new(animalData.OffsetX or 0, animalData.OffsetY or 0, animalData.OffsetZ or 0)
		local result = AnimalServerHandler:GetAnimalPos(count, index)
		local pos = result.Pos + offset
		local row = result.Row

		local animalInfo = {
			Animal = animal,
			Data = animalData,
			Position = pos,
			Row = row,
			Offset = 0,
			Constraint = AnimalServerHandler:ProcessAnimalConstraint(animal, animalPoint, pos),
			
			AnimationController = nil,
			Animator = nil,
			RunTrack = nil,
			IdleTrack = nil,
		}

		table.insert(playerInfo.AnimalList, animalInfo)
	end
	
	AnimalServerHandler:InitAnimation(playerInfo)
	PlayerInfoDic[player.UserId] = playerInfo
end

function AnimalServerHandler:Clear(player)
	local playerInfo = PlayerInfoDic[player.UserId]
	if playerInfo then
		if playerInfo.UpdateFunction then
			EventManager:Remove(EventManager.Define.RefreshPlayerStatus, playerInfo.UpdateFunction)
		end
		
		for _, info in ipairs(playerInfo.AnimalList) do
			info.Animal:Destroy()
		end
	end
	
	PlayerInfoDic[player.UserId] = nil
end

-- Animation

function AnimalServerHandler:InitAnimation(playerInfo)
	for _, animalInfo in ipairs(playerInfo.AnimalList) do
		animalInfo.AnimationController = animalInfo.Animal:FindFirstChildOfClass("AnimationController")
		animalInfo.Animator = animalInfo.AnimationController:FindFirstChildOfClass("Animator") or Instance.new("Animator", animalInfo.AnimationController)
		animalInfo.RunTrack = animalInfo.Animator:LoadAnimation(animalInfo.AnimationController:FindFirstChild("Run"))
		animalInfo.RunTrack.Looped = true
		animalInfo.IdleTrack =  animalInfo.Animator:LoadAnimation(animalInfo.AnimationController:FindFirstChild("Idle"))
		animalInfo.IdleTrack.Looped = true
	end
	
	playerInfo.UpdateFunction = function(param)
		local player = param.Player
		if player ~= playerInfo.Player then return end
		local status = param.Status
		if status == Define.PlayerStatus.Gaming then
			playerInfo.IsGaming = true
		elseif status == Define.PlayerStatus.Training  then
			playerInfo.IsTraining = true	
		else
			playerInfo.IsGaming = false
			playerInfo.IsTraining = false	
		end
	end

	EventManager:Listen(EventManager.Define.RefreshPlayerStatus, playerInfo.UpdateFunction)
	AnimalServerHandler:PlayIdle(playerInfo)
end

function AnimalServerHandler:PlayRun(playerInfo)
	for _, animalInfo in ipairs(playerInfo.AnimalList) do
		if animalInfo.RunTrack and not animalInfo.RunTrack.IsPlaying then
			animalInfo.RunTrack:Play(0.1)
		end

		if animalInfo.IdleTrack and animalInfo.IdleTrack.IsPlaying then
			animalInfo.IdleTrack:Stop(0.05)
		end
	end
end

function AnimalServerHandler:PlayIdle(playerInfo)
	for _, animalInfo in ipairs(playerInfo.AnimalList) do
		if animalInfo.IdleTrack and not animalInfo.IdleTrack.IsPlaying then
			animalInfo.IdleTrack:Play(0.1)
		end
		
		if animalInfo.RunTrack and animalInfo.RunTrack.IsPlaying then
			animalInfo.RunTrack:Stop(0.2)
		end
	end
end

-- Constrasit

function AnimalServerHandler:ProcessAnimalConstraint(animal, point, position)
	local constraint = Util:GetChildByType(animal, "Animal2Car_Motor6D")
	if not constraint then
		constraint = Instance.new("Motor6D")
		constraint.Name = "Animal2Car_Motor6D"
		constraint.Parent = animal
	end

	constraint.Part0 = point
	constraint.Part1 = animal.RootPart
	constraint.C0 = CFrame.new(Vector3.zero)
	constraint.C1 = CFrame.new(position)
	return constraint
end

function AnimalServerHandler:Update(deltaTime)
	-- Rotate
	for _, playerInfo in pairs(PlayerInfoDic) do
		local player = playerInfo.Player
		local steer = 0
		local playerStatus = PlaeyrStatus:GetStatus(player)
		if playerStatus == Define.PlayerStatus.Training then
			steer = 0
		else
			steer = AnimalServerHandler:GetPlayerInputX(player)
		end

		for i, animalInfo in ipairs(playerInfo.AnimalList) do
			local row = animalInfo.Row
			local fade = 1 - (row - 1) * 0.15
			fade = math.clamp(fade, 0.4, 1)
			local targetOffset = steer * math.rad(MaxRotate) * fade

			local current = animalInfo.Offset
			local speedTurn = 4.0
			local speedReturn = 20.0
			if math.abs(targetOffset) < 0.01 then
				animalInfo.Offset = current + (0 - current) * math.min(deltaTime * speedReturn, 1)
			else
				animalInfo.Offset = current + (targetOffset - current) * math.min(deltaTime * speedTurn, 1)
			end

			animalInfo.Constraint.C1 = CFrame.new(animalInfo.Position) * CFrame.Angles(0, animalInfo.Offset, 0)
		end
	end
	
	-- Animation
	for _, playerInfo in pairs(PlayerInfoDic) do
		local player = playerInfo.Player
		local currentPos = playerInfo.RootPart.Position
		local delta = (currentPos - playerInfo.LastPos).Magnitude
		local isMoving = false
		if delta > 0.01 then
			playerInfo.LastPos = currentPos
			isMoving = true
		end
		
		if isMoving or playerInfo.IsTraining or playerInfo.IsGaming then
			AnimalServerHandler:PlayRun(playerInfo)
		else
			AnimalServerHandler:PlayIdle(playerInfo)
		end
	end
end

return AnimalServerHandler