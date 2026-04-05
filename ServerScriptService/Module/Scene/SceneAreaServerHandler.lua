local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local SceneManager = require(game.ReplicatedStorage.ScriptAlias.SceneManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ResourcesManager = require(game.ReplicatedStorage.ScriptAlias.ResourcesManager)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)

local Define = require(game.ReplicatedStorage.Define)

local SceneAreaServerHandler = {}

SceneAreaServerHandler.AreaPointList = {}
SceneAreaServerHandler.AreaInfoList = {}
SceneAreaServerHandler.AreaCount = 0

SceneAreaServerHandler.OnCreateArea = {}
SceneAreaServerHandler.OnClearArea = {}

function SceneAreaServerHandler:Init()
	if not SceneManager.AreaList then return end
	local areaPointList = {}
	for areaIndex, area in ipairs(SceneManager.AreaList) do
		local areaInfo = {
			Player = nil,
			Index = areaIndex,
			Area = area,
			SpawnLocation = area:FindFirstChild("SpawnLocation"),
			ThemeKey = "None",
			ThemeList = {},
		}
		
		local themeRoot = area:FindFirstChild("Theme")
		if themeRoot then
			local themeList = themeRoot:GetChildren()
			for themeIndex, theme in ipairs(themeList) do
				local themeInfo = {
					Theme = theme,
					ThemeKey = theme.Name,
					PlayerInfoPart = theme:FindFirstChild("PlayerInfo"),
				}

				table.insert(areaInfo.ThemeList, themeInfo)
			end
		end
		
		table.insert(areaPointList, area)
		table.insert(SceneAreaServerHandler.AreaInfoList, areaInfo)
		
		--SceneAreaServerHandler:SwitchTheme(areaIndex, "Default")
	end
	
	SceneAreaServerHandler.AreaPointList = areaPointList
	SceneAreaServerHandler.AreaCount = #areaPointList

	PlayerManager:HandleCharacterAddRemove(function(player, character)
		SceneAreaServerHandler:OnPlayerAdded(player, character)
	end, function(player, character)
		SceneAreaServerHandler:OnPlayerRemoved(player, character)
	end)
end

-----------------------------------------------------------------------------------------------
-- Player Add / Remove

function SceneAreaServerHandler:OnPlayerAdded(player, character)
	local areaInfo = SceneAreaServerHandler:GetEmptyArea()
	if areaInfo then
		areaInfo.Player = player
		SceneAreaServerHandler:CreateArea(player, areaInfo)
		
		SceneAreaServerHandler:ResetPlayerPos(player)

		local themeRequest = require(game.ServerScriptService.ScriptAlias.Theme)
		local currentThemeKey = themeRequest:GetCurrentTheme(player)
		areaInfo.ThemeKey = currentThemeKey
		SceneAreaServerHandler:BroadcastRefreshArea()
	end
end

function SceneAreaServerHandler:ResetPlayerPos(player)
	local areaInfo = SceneAreaServerHandler:GetAreaByPlayer(player)
	if areaInfo then
		PlayerManager:SetCFrameToPart(player, areaInfo.SpawnLocation)
	end
end

function SceneAreaServerHandler:OnPlayerRemoved(player, character)
	local areaInfo = SceneAreaServerHandler:GetAreaByPlayer(player)
	if areaInfo then
		areaInfo.Player = nil
		areaInfo.ThemeKey = nil
		SceneAreaServerHandler:ClearArea(player, areaInfo)
		SceneAreaServerHandler:BroadcastRefreshArea()
	end
end

function SceneAreaServerHandler:CreateBroadcastInfoList()
	local result = {}
	for index, areaInfo in ipairs(SceneAreaServerHandler.AreaInfoList) do
		local playerID = nil
		if areaInfo.Player then
			playerID = areaInfo.Player.UserId
		end

		local info = {
			Index = index,
			PlayerID = playerID,
			ThemeKey = areaInfo.ThemeKey,
		}

		table.insert(result, info)
	end
	
	return result
end

function SceneAreaServerHandler:BroadcastRefreshArea()
	local areaInfoList = SceneAreaServerHandler:CreateBroadcastInfoList()
	EventManager:DispatchToAllClient(EventManager.Define.RefreshArea, areaInfoList)
	EventManager:Dispatch(EventManager.Define.RefreshArea, areaInfoList)
end

function SceneAreaServerHandler:GetEmptyArea()
	for index, areaInfo in ipairs(SceneAreaServerHandler.AreaInfoList) do
		if areaInfo.Player == nil then
			return areaInfo
		end
	end

	return nil
end

function SceneAreaServerHandler:GetAeraByIndex(index)
	return SceneAreaServerHandler.AreaInfoList[index]
end

function SceneAreaServerHandler:GetAreaByPlayer(player)
	for index, areaInfo in ipairs(SceneAreaServerHandler.AreaInfoList) do
		if areaInfo.Player == player then
			return areaInfo
		end
	end

	return nil
end

-----------------------------------------------------------------------------------------------
-- Area Create / Clear

function SceneAreaServerHandler:RefreshArea(player)
	local areaInfo = SceneAreaServerHandler:GetAeraByPlayer(player)
	local areaIndex = areaInfo.Index
	SceneAreaServerHandler:ClearArea(player, areaInfo)
	SceneAreaServerHandler:CreateArea(player, areaInfo)
end

function SceneAreaServerHandler:CreateArea(player, areaInfo)
	for index, func in ipairs(SceneAreaServerHandler.OnCreateArea) do
		pcall(func, player, areaInfo)
	end
	
	SceneAreaServerHandler:RefreshPlayerInfo(areaInfo)
end

function SceneAreaServerHandler:ClearArea(player, areaInfo)
	for index, func in ipairs(SceneAreaServerHandler.OnClearArea) do
		pcall(func, player, areaInfo)
	end
	
	SceneAreaServerHandler:RefreshPlayerInfo(areaInfo)
end

-----------------------------------------------------------------------------------------------
-- Player Info

function SceneAreaServerHandler:RefreshPlayerInfo(areaInfo)
	local player = areaInfo.Player
	for _, themeInfo in ipairs(areaInfo.ThemeList) do
		if themeInfo.PlayerInfoPart then
			if player then
				local playerInfo = {
					Name = player.Name,
				}

				UIInfo:SetInfo(themeInfo.PlayerInfoPart, playerInfo)	
				PlayerManager:GetHeadIconAsync(player, function(icon)
					UIInfo:SetValue(themeInfo.PlayerInfoPart, "HeadIcon", icon)
				end)
			else
				local playerInfo = {
					Name = "",
					HeadIcon = "",
				}

				UIInfo:SetInfo(themeInfo.PlayerInfoPart, playerInfo)	
			end

		end
	end
end

return SceneAreaServerHandler
