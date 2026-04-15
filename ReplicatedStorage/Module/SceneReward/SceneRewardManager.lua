local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local ResourcesManager = require(game.ReplicatedStorage.ScriptAlias.ResourcesManager)
local TriggerArea = require(game.ReplicatedStorage.ScriptAlias.TriggerArea)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local SceneAreaManager = require(game.ReplicatedStorage.ScriptAlias.SceneAreaManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local SceneRewardManager = {}

SceneRewardManager.RewardSaveInfo = nil

local RewardInfoCache = {}

function SceneRewardManager:Init() 
	task.wait()
	
	SceneRewardManager:HideOthers()
	SceneRewardManager:Spawn()
	
	EventManager:Listen(EventManager.Define.RefreshArea, function()
		SceneRewardManager:Clear()
		SceneRewardManager:Spawn()
	end)
end

function SceneRewardManager:HideOthers()
	local currentAreaIndex = SceneAreaManager:GetCurrentAreaIndex()
	for areaIndex, areaInfo in ipairs(SceneAreaManager.AreaInfoList) do
		if areaIndex ~= currentAreaIndex then
			for _, themeInfo in ipairs(areaInfo.ThemeList) do
				local rewardRoot = themeInfo.Theme:FindFirstChild("SceneReward")
				if rewardRoot then
					rewardRoot:Destroy()
				end
			end
		end
	end
end

function SceneRewardManager:Spawn()
	local themeKey = SceneAreaManager:GetCurrentThemeKey()
	local configName = "SceneReward" .. themeKey
	local themeInfo = SceneAreaManager:GetCurrentThemeInfo()
	local rewardRoot = themeInfo.Theme:FindFirstChild("SceneReward")
	if not rewardRoot then return end
	
	local themeInfoDic = RewardInfoCache[themeKey]
	if not themeInfoDic then
		themeInfoDic = {}
		SceneRewardManager.RewardSaveInfo = NetClient:RequestWait("SceneReward", "GetThemeInfo", { ThemeKey = themeKey })
		RewardInfoCache[themeKey] = themeInfoDic
		
		--warn(rewardSaveInfo)
		
		local rewardItemList = rewardRoot:GetChildren()
		local prefix = "SceneReward"
		for _, rewardItem in ipairs(rewardItemList) do
			local name = rewardItem.Name
			if not Util:IsStrStartWith(name, prefix) then continue end
			local id = tonumber(string.sub(name, #prefix + 1, #name))
			local data = ConfigManager:GetData(configName, id)
			local key = "SceneReward_" .. tostring(id)
			local state = SceneRewardManager.RewardSaveInfo[key]
			if state == nil then
				state = false
			end

			local info = {
				Item = rewardItem,
				ID = id,
				Key = key,
				ThemeKey = themeKey,
				Data = data,
				State = state,
			}

			TriggerArea:Handle(rewardItem.Trigger, function()
				NetClient:Request("SceneReward", "GetReward", { ID = id, ThemeKey = themeKey }, function(result)
					if result.Success then
						info.State = true
						Util:DeActiveObject(info.Item)				
						SceneRewardManager.RewardSaveInfo[key] = true
						EventManager:Dispatch(EventManager.Define.GetSceneReward)
						
						--warn(result)
						local rewardList = result.RewardList
						for _, data in ipairs(rewardList) do
							UIManager:ShowMessageWithIcon(data.Icon, "Got "..data.Description)
							task.wait()
						end
					else
						UIManager:ShowMessage(result.Message)
					end
				end)
			end, function()

			end, true)
			
			themeInfoDic[key] = info
		end	
	end
	
	for key, info in pairs(themeInfoDic) do
		if info.State then
			Util:DeActiveObject(info.Item)
		else
			Util:ActiveObject(info.Item)
		end
	end
	
	EventManager:Dispatch(EventManager.Define.RefreshSceneReward)
end

function SceneRewardManager:Clear()
	for themeKey, themeInfoDic in ipairs(RewardInfoCache) do
		for key, info in pairs(themeInfoDic) do
			Util:DeActiveObject(info.Item)
		end
	end
end

return SceneRewardManager
