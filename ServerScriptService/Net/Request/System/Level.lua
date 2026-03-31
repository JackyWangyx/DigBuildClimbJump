local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)

local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)
local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local PlayerProperty = require(game.ServerScriptService.ScriptAlias.PlayerProperty)

local RebirthRequest = require(game.ServerScriptService.ScriptAlias.Rebirth)

local Define = require(game.ReplicatedStorage.Define)

local Level = {}

function LoadInfo(player)
	local saveInfo = PlayerPrefs:GetModule(player, "Level")
	return saveInfo
end

function Level:CheckLevel(player, param)
	local id = param.ID
	local saveInfo = LoadInfo(player)
	local levelInfo = saveInfo[tostring(id)]
	if not levelInfo then
		levelInfo = {
			Unlock = false,
		}
		
		if id == 1 then
			levelInfo.Unlock = true
		end
		
		saveInfo[tostring(id)] = levelInfo
	end
	
	if not levelInfo.Unlock then
		local levelData = ConfigManager:GetData("Level", id)
		local rebirthInfo = RebirthRequest:GetInfo(player)
		local power = PlayerRecord:GetValue(player, Define.PlayerRecord.MaxTrainingPower)

		--print(levelInfo, levelData, rebirthInfo, power)
		local c1 = rebirthInfo.ID >= levelData.RequireRebirth
		local c2 = power >= levelData.RequirePower
		if c1 and c2 then
			levelInfo.Unlock = true
			
			PlayerRecord:AddValue(player, PlayerRecord.Define.TotalUnlockLevel, 1)
			EventManager:Dispatch(EventManager.Define.QuestUnlockLevel, {
				Player = player,
				Value = 1,
			})
			
			return true
		else
			return false
		end
	else
		return true
	end
end

return Level