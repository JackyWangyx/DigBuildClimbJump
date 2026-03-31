local RunService = game:GetService("RunService")

local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local LogUtil = require(game.ReplicatedStorage.ScriptAlias.LogUtil)

local Define = require(game.ReplicatedStorage.Define)

local SceneManager = {}

SceneManager.Config = nil
SceneManager.CurrentLevelName = nil
SceneManager.LevelRoot = nil
SceneManager.AreaList = nil

function SceneManager:Init()
	if RunService:IsServer() then
		SceneManager.Config = game.ServerStorage.Level:WaitForChild("SceneConfig")
		local levelConfig = SceneManager.Config:GetDescendants()[1]
		SceneManager.CurrentLevelName = levelConfig.Name
		local levelPrefab = game.ServerStorage.Level:FindFirstChild(SceneManager.CurrentLevelName)
		local levelRoot = nil
		if levelPrefab then
			levelRoot = levelPrefab:Clone()
		else
			levelRoot = game.Workspace:FindFirstChild(SceneManager.CurrentLevelName )
		end 
		
		levelRoot.Name = "LevelRoot"
		levelRoot.Parent = game.Workspace
		local levelNameLabel = Instance.new("StringValue")
		levelNameLabel.Name = "LevelName"
		levelNameLabel.Value = SceneManager.CurrentLevelName
		levelNameLabel.Parent = levelRoot
		SceneManager.LevelRoot = levelRoot
		
		LogUtil:Log("[Server] Scene Load Success! ", SceneManager.CurrentLevelName)
	else
		SceneManager.LevelRoot = game.Workspace:WaitForChild("LevelRoot")
		SceneManager.CurrentLevelName = SceneManager.LevelRoot:WaitForChild("LevelName").Value
		LogUtil:Log("[Client] Scene Load Success!")
	end
	
	local areaRoot = SceneManager.LevelRoot:FindFirstChild("Area")
	if areaRoot then
		SceneManager.AreaList = areaRoot:GetChildren()
		if SceneManager.AreaList  then
			SceneManager.AreaList = Util:ListSortByPartName(SceneManager.AreaList)
		end
		
		if RunService:IsClient() then
			local sceneAreaManager = require(game.ReplicatedStorage.ScriptAlias.SceneAreaManager)
			local serverAreaInfoList = NetClient:RequestWait("Scene", "GetAreaInfoList")
			sceneAreaManager.ServerAeraInfoList = serverAreaInfoList
			sceneAreaManager:InitSelfAreaIndex()
		end
	end
end

return SceneManager
