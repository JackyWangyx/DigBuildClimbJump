local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local EventMananger = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local SoundMnaager = require(game.ReplicatedStorage.ScriptAlias.SoundManager)

local RunnerMiningTrackUpdator = require(game.ReplicatedStorage.ScriptAlias.RunnerMiningTrackUpdator)
local RunnerGameManager = require(game.ReplicatedStorage.ScriptAlias.RunnerGameManager)

local Define = require(game.ReplicatedStorage.Define)

local Game = {}

function Game:Update(player, param)
	local gameInfo = param.GameInfo
	local playerList = param.PlayerList
	local localPlayerInfo = param.LocalPlayerInfo
	for playerID, info in pairs(playerList) do
		info.ID = tonumber(playerID)
	end
	
	RunnerMiningTrackUpdator:OnBoardcast(param)
	EventMananger:Dispatch(EventMananger.Define.RefreshGameInfo, param)
end

function Game:CountDown(player, param)
	local value = param.Value
	if value == 3 then
		SoundMnaager:PlaySFX(SoundMnaager.Define.CountDown)
	end	
end

function Game:GetCoinReward(player, param)
	RunnerMiningTrackUpdator:OnGetCoinReward()
end

function Game:OnEnter(player, param)
	RunnerGameManager:OnEnter(player)
	RunnerMiningTrackUpdator:OnEnter(player)
end

function Game:OnStart(player, param)
	RunnerGameManager:OnStart(player)
	RunnerMiningTrackUpdator:OnStart(player)
end

function Game:OnLeave(player, param)
	RunnerGameManager:OnLeave(player)
	RunnerMiningTrackUpdator:OnLeave(player)
end

function Game:OnFinish(player, param)
	RunnerGameManager:OnFinish(player)
	RunnerMiningTrackUpdator:OnFinish(player)
end

function Game:OnReset(player, param)
	RunnerMiningTrackUpdator:OnBreakMine(player)
end


return Game
