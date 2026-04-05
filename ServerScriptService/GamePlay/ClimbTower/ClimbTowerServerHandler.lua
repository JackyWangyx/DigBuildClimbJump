local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local SceneManager = require(game.ReplicatedStorage.ScriptAlias.SceneManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ResourcesManager = require(game.ReplicatedStorage.ScriptAlias.ResourcesManager)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local UTween = require(game.ReplicatedStorage.ScriptAlias.UTween)

local SceneAreaServerHandler = require(game.ServerScriptService.ScriptAlias.SceneAreaServerHandler)
local ClimbTowerDefine = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerDefine)

local ClimbTowerRequest = nil
local ThemeRequest = nil

local Define = require(game.ReplicatedStorage.Define)

local ClimbTowerTowerServerHandler = {}

ClimbTowerTowerServerHandler.TowerList = {}

function ClimbTowerTowerServerHandler:Init()
	ClimbTowerRequest = require(game.ServerScriptService.ScriptAlias.ClimbTower)
	ThemeRequest = require(game.ServerScriptService.ScriptAlias.Theme)
	
	ClimbTowerTowerServerHandler:InitTower(SceneAreaServerHandler.AreaPointList)
	
	table.insert(SceneAreaServerHandler.OnCreateArea, function(player, areaInfo)
		ClimbTowerTowerServerHandler:OnPlayerAdded(player, areaInfo)
	end)
	
	table.insert(SceneAreaServerHandler.OnClearArea, function(player, areaInfo)
		ClimbTowerTowerServerHandler:OnPlayerRemoved(player, areaInfo)
	end)
	
	EventManager:Listen(EventManager.Define.RefreshTower, function(param)
		local player = param.Player
		task.spawn(function()
			ClimbTowerTowerServerHandler:RefreshTower(player)
		end)
	end)
	
	EventManager:Listen(EventManager.Define.RefreshArea, function(serverAreaInfoList)
		--print(serverAreaInfoList, ClimbTowerTowerServerHandler.TowerList)
		for index, areaInfo in ipairs(serverAreaInfoList) do
			local towerInfo = ClimbTowerTowerServerHandler.TowerList[index]
			if not towerInfo then continue end
			if areaInfo.ThemeKey ~= nil and areaInfo.ThemeKey ~= towerInfo.ThemeKey and towerInfo.Player ~= nil then
				task.spawn(function()
					ClimbTowerTowerServerHandler:RefreshTower(towerInfo.Player)
				end)
			end
		end	
	end)
end

function ClimbTowerTowerServerHandler:InitTower(towerPointList)
	for index = 1, SceneAreaServerHandler.AreaCount do
		local towerRoot = SceneAreaServerHandler.AreaPointList[index]:FindFirstChild("Game")
		if not towerRoot then continue end
		
		local towerPos = towerRoot:FindFirstChild("TowerPos")
		local towerEndList = Util:GetAllChildByName(towerRoot, "TowerEnd", true)

		local areaInfo = SceneAreaServerHandler.AreaInfoList[index]
		local towerInfo = {
			Index = index,
			Player = nil,
			TowerPos = towerPos,
			TowerRoot = towerRoot,
			EndList = towerEndList,
			Tower = nil,
			ThemeKey = areaInfo.ThemeKey,
		}
		
		areaInfo.TowerInfo = towerInfo
		table.insert(ClimbTowerTowerServerHandler.TowerList, towerInfo)
		
		Util:DeActiveObject(towerInfo.End)
	end
end

function ClimbTowerTowerServerHandler:OnPlayerAdded(player, areaInfo)
	local towerInfo = areaInfo.TowerInfo
	task.spawn(function()
		towerInfo.Player = player
		ClimbTowerTowerServerHandler:CreateTower(towerInfo)
	end)	
end

function ClimbTowerTowerServerHandler:OnPlayerRemoved(player, areaInfo)
	local towerInfo = areaInfo.TowerInfo
	towerInfo.Player = nil
	ClimbTowerTowerServerHandler:ClearTower(towerInfo)
end

function ClimbTowerTowerServerHandler:GetTowerByIndex(index)
	return SceneAreaServerHandler.AreaInfoList[index].TowerInfo
end

function ClimbTowerTowerServerHandler:GetTowerByPlayer(player)
	for index, areaInfo in ipairs(SceneAreaServerHandler.AreaInfoList) do
		if areaInfo.TowerInfo.Player == player then
			return areaInfo.TowerInfo
		end
	end

	return nil
end

function ClimbTowerTowerServerHandler:RefreshTower(player)
	local towerInfo = ClimbTowerTowerServerHandler:GetTowerByPlayer(player)
	--ClimbTowerTowerServerHandler:ClearTower(towerInfo)
	ClimbTowerTowerServerHandler:CreateTower(towerInfo)
end

function ClimbTowerTowerServerHandler:CreateTower(towerInfo)
	local player = towerInfo.Player
	if not player then
		return
	end
	
	local themeKey = ThemeRequest:GetCurrentTheme(player)
	local themeData = ConfigManager:SearchData("Theme", "ThemeKey", themeKey)
	local themeInfo = ClimbTowerRequest:GetThemeInfo(player, { ThemeKey = themeKey })
	local towerHeight = themeInfo.TowerHeight
	local cframe = towerInfo.TowerPos.CFrame
	
	local tower = nil
	--warn(towerInfo.ThemeKey, themeKey)
	if towerInfo.ThemeKey == themeKey and towerInfo.Tower then
		-- 已经存在相同的塔，不重新生成，重新计算位置
		tower = towerInfo.Tower
		
		local finalCFrame = towerInfo.TowerPos.CFrame * CFrame.new(0, towerHeight - themeData.Length, 0)
		local tweener = UTween:ModelPosition(tower, 
			finalCFrame.Position, 
			ClimbTowerDefine.Game.TowerUpgradeDuration)
		
		EventManager:DispatchToClient(player, ClimbTowerDefine.Event.BuildTower)
	else
		-- 主题变化
		-- 踢出游戏中玩家
		local gameServerHandler = require(game.ServerScriptService.ScriptAlias.ClimbTowerGameServerHandler)
		gameServerHandler:KickAllPlayers(towerInfo.Index)
		
		-- 重新生成塔
		if towerInfo.Tower then
			ClimbTowerTowerServerHandler:ClearTower(towerInfo)
		end
		
		towerInfo.ThemeKey = themeKey
		local towerPrefab = ResourcesManager:Load(themeData.TowerPrefab)
		tower = towerPrefab:Clone()
		tower.Name = "Tower"
		towerInfo.Tower = tower
		
		tower.Parent = towerInfo.TowerRoot
		
		local finalCFrame = towerInfo.TowerPos.CFrame * CFrame.new(0, towerHeight - themeData.Length, 0)
		tower:PivotTo(finalCFrame)
	end
end

function ClimbTowerTowerServerHandler:ClearTower(towerInfo)
	local towerIndex = towerInfo.Index
	local gameServerHandler = require(game.ServerScriptService.ScriptAlias.ClimbTowerGameServerHandler)
	local playerCache = gameServerHandler:GetPlayerCache()
	for player, playerInfo in pairs(playerCache) do
		if playerInfo.TowerIndex == towerIndex then
			gameServerHandler:Exit(player)
			EventManager:DispatchToClient(player, ClimbTowerDefine.Event.Reset)
		end
	end

	if towerInfo.Tower then
		towerInfo.Tower:Destroy()
		towerInfo.Tower = nil
	end
	
	if towerInfo.End then
		Util:DeActiveObject(towerInfo.End)
	end
end

return ClimbTowerTowerServerHandler
