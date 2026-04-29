local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)

local PlayerProperty = require(game.ServerScriptService.ScriptAlias.PlayerProperty)
local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)
local IAPServer = require(game.ServerScriptService.ScriptAlias.IAPServer)
local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)

local RewardHandler = require(game.ServerScriptService.ScriptAlias.RewardHandler)

local Define = require(game.ReplicatedStorage.Define)

local SceneReward = {}

function LoadInfo(player)
	local saveInfo = PlayerPrefs:GetModule(player, "SceneReward")
	return saveInfo
end

function SceneReward:GetThemeInfo(player, param)
	local themeKey = param.ThemeKey
	local saveInfo = LoadInfo(player)
	local themeInfo = saveInfo[themeKey]
	if not themeInfo then
		themeInfo = {}
		saveInfo[themeKey] = themeInfo
	end
	
	--warn(themeInfo)
	return themeInfo
end

function SceneReward:GetReward(player, param)
	local id = param.ID
	local themeKey = param.ThemeKey
	local themeInfo = SceneReward:GetThemeInfo(player, param)
	local key = "SceneReward_" .. tostring(id) -- Key 加前缀，否则数字Key 会被通信压缩算法错误解析
	local rewardState = themeInfo[key]
	
	if rewardState == nil or not rewardState then
		themeInfo[key] = true	
		local data = ConfigManager:GetData("SceneReward" .. themeKey, id)
		local result = RewardHandler:GetRewardRequest(player, data)
		
		if result.Success then
			local analyticsKey = AnalyticsManager.Define.GetSceneReward .. "_" .. themeKey .. "_" .. id
			AnalyticsManager:Event(player, analyticsKey)
			
			-----------------------------------------------------------------------
			-- GameFunnel
			local themeIndexStr = string.match(themeKey, "%d+$")
			local themeIndex = tonumber(themeIndexStr)
			
			local stepIndex = -1
			
			if themeIndex == 1 and id == 1 then
				stepIndex = 2
			elseif themeIndex == 1 and id == 2 then
				stepIndex = 3
			elseif themeIndex == 1 and id == 3 then
				stepIndex = 4
			elseif themeIndex == 1 and id == 4 then
				stepIndex = 5
			elseif themeIndex == 1 and id == 5 then
				stepIndex = 6
			elseif themeIndex == 2 and id == 1 then
				stepIndex = 8
			elseif themeIndex == 2 and id == 2 then
				stepIndex = 9
			elseif themeIndex == 2 and id == 3 then
				stepIndex = 10
			elseif themeIndex == 2 and id == 4 then
				stepIndex = 11
			elseif themeIndex == 2 and id == 5 then
				stepIndex = 12
			end
			
			if stepIndex > 1 then
				AnalyticsManager:Funnel(player, AnalyticsManager.Define.Game, stepIndex, analyticsKey)
			end
			
			-----------------------------------------------------------------------
		end
		
		return result
	else
		return {
			Success = false,
			Message = Define.Message.RewardGotten,
		}
	end
end

return SceneReward