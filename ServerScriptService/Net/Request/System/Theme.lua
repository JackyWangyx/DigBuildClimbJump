local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)

local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)
local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local PlayerProperty = require(game.ServerScriptService.ScriptAlias.PlayerProperty)

local Define = require(game.ReplicatedStorage.Define)

local Theme = {}

function LoadInfo(player)
	local saveInfo = PlayerPrefs:GetModule(player, "Theme")
	return saveInfo
end

function Theme:Init()
	EventManager:Listen(EventManager.Define.GetWins, function(param)
		local player = param.Player
		if Theme:CheckCanUnlockNext(player) then
			EventManager:DispatchToClient(player, EventManager.Define.RefreshUnlockThemeTip)
		end
	end)
end

function Theme:GetAreaInfoList(player, param)
	local sceneAreaServerHandler = require(game.ServerScriptService.ScriptAlias.SceneAreaServerHandler)
	local result = sceneAreaServerHandler:CreateBroadcastInfoList()
	return result
end

function Theme:GetInfoList(player)
	local saveInfo = LoadInfo(player)
	local infoList = saveInfo.ThemeList
	if not infoList then
		infoList = {}
		local dataList = ConfigManager:GetDataList("Theme")
		for index, data in ipairs(dataList) do
			local info = {
				ID = data.ID,
				ThemeKey = data.ThemeKey,
				IsUnlock = false,
			}
			
			table.insert(infoList, info)
		end
		
		infoList[1].IsUnlock = true
		saveInfo.ThemeList = infoList
		saveInfo.SelectThemeKey = dataList[1].ThemeKey
	end
	
	return infoList
end

function Theme:GetCurrentTheme(player)
	local saveInfo = LoadInfo(player)
	local result = saveInfo.SelectThemeKey
	if not saveInfo.SelectThemeKey then
		local data = ConfigManager:GetData("Theme", 1)
		saveInfo.SelectThemeKey = data.ThemeKey
		result = saveInfo.SelectThemeKey
	end
	
	return result
end

function Theme:GetInfo(player, param)
	local themeKey = param.ThemeKey
	local infoList = Theme:GetInfoList(player)
	for index, info in ipairs(infoList) do
		if info.ThemeKey == themeKey then
			return info
		end
	end
	
	return nil
end

function Theme:SwitchTheme(player, param)
	local themeKey = param.ThemeKey
	local info = Theme:GetInfo(player, param)
	local saveInfo = LoadInfo(player)
	
	if info.IsUnlock then
		saveInfo.SelectThemeKey = themeKey
		local sceneAreaServerHandler = require(game.ServerScriptService.ScriptAlias.SceneAreaServerHandler)
		local areaInfo = sceneAreaServerHandler:GetAreaByPlayer(player)
		if areaInfo then
			areaInfo.ThemeKey = themeKey
			sceneAreaServerHandler:BroadcastRefreshArea()
		end
		
		return true
	else
		return false
	end
end

function Theme:CheckCanUnlockNext(player)
	local infoList = Theme:GetInfoList(player)
	local accountRequest = require(game.ServerScriptService.ScriptAlias.Account)
	local remainWins = accountRequest:GetWins(player)
	for index, info in ipairs(infoList) do
		if not info.IsUnlock then
			local data = ConfigManager:GetData("Theme", info.ID)
			if remainWins >= data.CostWins  then
				return true
			end
		end
	end
	
	return false
end

function Theme:UnlockTheme(player, param)
	local themeKey = param.ThemeKey
	local info = Theme:GetInfo(player, param)
	if info.IsUnlcok then
		return {
			Success = false,
			Message = "Not Unlock!",
		}
	end

	local data = ConfigManager:GetData("Theme", info.ID)
	local accountRequest = require(game.ServerScriptService.ScriptAlias.Account)
	local remainWins = accountRequest:GetWins(player)
	if remainWins < data.CostWins  then
		return {
			Success = false,
			Message = Define.Message.WinsNotEnough,
		}
	end

	accountRequest:SpendWins(player, { Value = data.CostWins })
	info.IsUnlock = true
	
	local analyticsKey = AnalyticsManager.Define.UnlockTheme .. "_" .. themeKey
	AnalyticsManager:Event(player, analyticsKey)
	
	-----------------------------------------------------------------------
	-- GameFunnel
	local themeIndexStr = string.match(themeKey, "%d+$")
	local themeIndex = tonumber(themeIndexStr)

	local stepIndex = -1

	if themeIndex == 2 then
		stepIndex = 7
	elseif themeIndex == 3 then
		stepIndex = 13
	end

	if stepIndex > 1 then
		AnalyticsManager:Funnel(player, AnalyticsManager.Define.Game, stepIndex, analyticsKey)
	end
	
	-----------------------------------------------------------------------
	
	return {
		Success = true,
		Message = "",
	}
end

return Theme