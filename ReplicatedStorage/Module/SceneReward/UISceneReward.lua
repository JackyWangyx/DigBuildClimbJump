local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local SceneAreaManager = require(game.ReplicatedStorage.ScriptAlias.SceneAreaManager)
local SceneRewardManager = require(game.ReplicatedStorage.ScriptAlias.SceneRewardManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local UISceneReward = {}

UISceneReward.UIRoot = nil

function UISceneReward:Init(root)
	UISceneReward.UIRoot = root
	
	UISceneReward:Refresh()
	
	EventManager:Listen(EventManager.Define.RefreshSceneReward, function()
		UISceneReward:Refresh()
	end)
	
	EventManager:Listen(EventManager.Define.GetSceneReward, function()
		UISceneReward:Refresh()
	end)
end

function UISceneReward:Refresh()
	local rewardSaveInfo = SceneRewardManager.RewardSaveInfo
	if rewardSaveInfo == nil then return end
	
	--warn(rewardSaveInfo)
	local themeKey = SceneAreaManager:GetCurrentThemeKey()
	local dataList = ConfigManager:GetDataList("SceneReward" .. themeKey)
	
	local prefix = "SceneReward_"
	for index, data in ipairs(dataList) do
		local key = prefix .. data.ID
		local state = rewardSaveInfo[key]
		if state == nil then state = false end
		
		local partName = "Image_SceneReward_" .. data.ID
		local part = Util:GetChildByName(UISceneReward.UIRoot, partName)
		--warn(partName, part, state)
		if part then
			part.Visible = not state
		end
	end
end

return UISceneReward
