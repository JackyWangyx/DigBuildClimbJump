local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIClickGame = require(game.ReplicatedStorage.ScriptAlias.UIClickGame)

local ClickGameDefine = require(game.ReplicatedStorage.ScriptAlias.ClickGameDefine)
local Define = require(game.ReplicatedStorage.Define)

local ClickGame = {}

local GameModeType = {
	Running = 1,
	Traning = 2,
}

local GameMode = nil

function ClickGame:Init()
	UIClickGame.OnItemSpawn = function(item)
		ClickGame:OnItemSpawn(item)
	end
	
	UIClickGame.OnItemClick = function(item)
		ClickGame:OnItemClick(item)
	end
	
	UIClickGame.OnItemUpdate = function(item, deltaTime)
		ClickGame:OnItemUpdate(deltaTime)
	end
	
	UIClickGame.OnItemDeSpawn = function(item)
		ClickGame:OnItemDeSpawn(item)
	end
	
	ClickGame:SetParam(ClickGameDefine.DefaultParam)
	
	--EvemtManager:Listen(EvemtManager.Define.GameFinish, function()
	--	ClickGame:GameEnd()
	--end)
	
	--EventManager:Listen(EventManager.Define.TrainingStart, function()
	--	GameMode = GameModeType.Traning
	--	UIClickGame.Param.ItemPrefab = Util:LoadPrefab("UIItem/UIClickTrainingItem")
	--	ClickGame:GameStart()
	--end)

	--EventManager:Listen(EventManager.Define.TrainingEnd, function()
	--	ClickGame:GameEnd()
	--end)
end

function ClickGame:SetParam(param)
	UIClickGame:SetParam(param)
end

function ClickGame:GameStart()
	UIClickGame:GameStart()
end

function ClickGame:GameEnd()
	UIClickGame:GameEnd()
end

function ClickGame:OnItemSpawn(item)
	item.ClickCount = 0
	ClickGame:RefreshItem(item)
end

function ClickGame:OnItemClick(item)
	item.ClickCount += 1
	ClickGame:RefreshItem(item)
end

function ClickGame:OnItemUpdate(item, deltaTime)
	
end

function ClickGame:OnItemDeSpawn(item)
	local click = item.ClickCount
	if click == 0 then return end
	NetClient:Request("ClickGame", "Click", { Value = click })
end

function ClickGame:RefreshItem(item)
	local info = {
		Count = item.ClickCount,
		ShowCount = item.ClickCount > 0,
		ShowTip = item.ClickCount == 0,
	}
	
	UIInfo:SetInfo(item.Part, info)
end

return ClickGame
