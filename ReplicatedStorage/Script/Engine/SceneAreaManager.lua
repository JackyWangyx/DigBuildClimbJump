local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local SceneManager = require(game.ReplicatedStorage.ScriptAlias.SceneManager)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)

local SceneAreaManager = {}

SceneAreaManager.AreaPointList = {}
SceneAreaManager.AreaInfoList = {}
SceneAreaManager.AreaCount = 0

SceneAreaManager.CurrentAreaIndex = -1
SceneAreaManager.CurrentThemeKey = nil
SceneAreaManager.ServerAeraInfoList = nil

function SceneAreaManager:Init()
	if not SceneManager.AreaList then return end
	local areaPointList = {}
	for areaIndex, area in ipairs(SceneManager.AreaList) do
		local areaInfo = {
			PlayerID = nil,
			Index = areaIndex,
			Area = area,
			OnlySelf = area:FindFirstChild("OnlySelf"),
			SpawnLocation = area:FindFirstChild("SpawnLocation"),		
			ThemeKey = nil,
			ThemeList = {},
			
			-- Additional
			ExitCollide = area:FindFirstChild("ExitCollide"),
			DownCollide = area:FindFirstChild("DownCollide"),
		}

		local themeRoot = area:FindFirstChild("Theme")
		if themeRoot then
			local themeList = Util:ListSortByPartName(themeRoot:GetChildren())
			for themeIndex, theme in ipairs(themeList) do
				local themeInfo = {
					Theme = theme,
					ThemeKey = theme.Name,
				}

				table.insert(areaInfo.ThemeList, themeInfo)
			end
		end

		table.insert(areaPointList, area)
		table.insert(SceneAreaManager.AreaInfoList, areaInfo)
	end

	SceneAreaManager.AreaPointList = areaPointList
	SceneAreaManager.AreaCount = #areaPointList
	
	EventManager:Listen(EventManager.Define.RefreshArea, function(serverAreaIndex)
		SceneAreaManager:RefreshServerAreaInfo(serverAreaIndex)
	end)
	
	SceneAreaManager:RefreshServerAreaInfo(SceneAreaManager.ServerAeraInfoList)
end

function SceneAreaManager:InitSelfAreaIndex()
	local player = game.Players.LocalPlayer
	for areaIndex, serverAreaInfo in ipairs(SceneAreaManager.ServerAeraInfoList) do
		if serverAreaInfo.PlayerID == player.UserId then
			SceneAreaManager.CurrentAreaIndex = areaIndex
			SceneAreaManager.CurrentThemeKey = serverAreaInfo.ThemeKey
		end
	end
end

function SceneAreaManager:RefreshServerAreaInfo(serverAreaInfoList)
	SceneAreaManager.ServerAeraInfoList = serverAreaInfoList
	SceneAreaManager:InitSelfAreaIndex()
	for areaIndex, serverAreaInfo in ipairs(serverAreaInfoList) do
		local areaInfo = SceneAreaManager.AreaInfoList[areaIndex]
		if serverAreaInfo.ThemeKey ~= areaInfo.ThemeKey then
			areaInfo.ThemeKey = serverAreaInfo.ThemeKey
			areaInfo.ThemeIndex = 1
			for themeIndex, themeInfo in ipairs(areaInfo.ThemeList) do
				if themeInfo.ThemeKey == serverAreaInfo.ThemeKey then
					areaInfo.ThemeIndex = themeIndex
					break
				end
			end
			
			SceneAreaManager:SwitchTheme(areaIndex, serverAreaInfo.ThemeKey)
		end
		
		if areaIndex == SceneAreaManager.CurrentAreaIndex then
			Util:ActiveObject(areaInfo.OnlySelf)
		else
			Util:DeActiveObject(areaInfo.OnlySelf)
		end
	end
end

function SceneAreaManager:ResetPlayerPos(player)
	local areaInfo = SceneAreaManager.AreaInfoList[SceneAreaManager.CurrentAreaIndex]
	if areaInfo then
		local rootPart = PlayerManager:GetHumanoidRootPart(player)
		if rootPart then
			rootPart.CFrame = CFrame.new(areaInfo.SpawnLocation.Position + Vector3.new(0, 5, 0))
		end
	end
end

function SceneAreaManager:SwitchTheme(areaIndex, themeKey)
	local areaInfo = SceneAreaManager.AreaInfoList[areaIndex]
	areaInfo.ThemeKey = themeKey
	local find = false
	for _, themeInfo in ipairs(areaInfo.ThemeList) do
		if themeInfo.ThemeKey == themeKey then
			Util:ActiveObject(themeInfo.Theme)
			find = true
		else
			Util:DeActiveObject(themeInfo.Theme)
		end
	end

	--if not find and #areaInfo.ThemeList > 0 then
	--	Util:ActiveObject(areaInfo.ThemeList[1].Theme)
	--end
end

return SceneAreaManager