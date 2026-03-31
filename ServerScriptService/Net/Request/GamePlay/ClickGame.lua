local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)

local PlayerState = require(game.ServerScriptService.ScriptAlias.PlayerStatus)
local PlayerProperty = require(game.ServerScriptService.ScriptAlias.PlayerProperty)
local PlayerRecord = require(game.ServerScriptService.ScriptAlias.PlayerRecord)

local RebirthRequiest = require(game.ServerScriptService.ScriptAlias.Rebirth)
local TrainingRequest = require(game.ServerScriptService.ScriptAlias.Training)
local AccountRequest = require(game.ServerScriptService.ScriptAlias.Account)

local ThemeRequest = require(game.ServerScriptService.ScriptAlias.Theme)
local AccountRequest = require(game.ServerScriptService.ScriptAlias.Account)

local ClimbTowerDefine = require(game.ReplicatedStorage.ScriptAlias.ClimbTowerDefine)
local Define = require(game.ReplicatedStorage.Define)

local ClickGame = {}

function ClickGame:Click(player, param)
	local click = param.Value
	
	---------------------------------------------------------------
	-- Runner
	
	--local status = PlayerState:GetStatus(player)
	--if status ~= Define.PlayerStatus.Gaming and status ~= Define.PlayerStatus.Training then return false end
	
	--local rebirthLevel = RebirthRequiest:GetLevel(player)
	--if status == Define.PlayerStatus.Gaming then
	--	local getCoinFactor = PlayerProperty:GetGamePropertyValue(player,  Define.PlayerProperty.GET_COIN_FACTOR)
	--	local value = math.round(click * getCoinFactor)
	--	AccountRequest:AddCoin(player, { Value = value })
	--elseif status == Define.PlayerStatus.Training then
	--	local getPowerFactor = PlayerProperty:GetGamePropertyValue(player,  Define.PlayerProperty.GET_POWER_FACTOR)
	--	local value = math.round(click * getPowerFactor)
	--	TrainingRequest:AddPower(player, { Value = value })	
	--end
	
	---------------------------------------------------------------
	-- RollerCoaster
	
	local getCoinFactor = PlayerProperty:GetGamePropertyValue(player, Define.PlayerProperty.GET_COIN_FACTOR)
	local themeKey = ThemeRequest:GetCurrentTheme(player)
	local themeData = ConfigManager:SearchData("Theme", "ThemeKey", themeKey)
	local rewardCoin = themeData.RewardCoin
	local gameGetCoinFactor = ClimbTowerDefine.Game.ClickGameGetCoinFactor
	local value = math.round(click * getCoinFactor * rewardCoin * gameGetCoinFactor)
	--print(click, getCoinFactor, gameGetCoinFactor, value)
	AccountRequest:AddCoin(player, { Value = value })
	
	PlayerRecord:AddValue(player, Define.PlayerRecord.TotalClick, click)
	return true
end

return ClickGame
