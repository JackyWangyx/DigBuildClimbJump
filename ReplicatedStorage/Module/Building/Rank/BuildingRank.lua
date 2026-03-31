local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local Building = require(game.ReplicatedStorage.ScriptAlias.Building)

local Define = require(game.ReplicatedStorage.Define)

local BuildingRank = {}

function BuildingRank:Handle(buildingPart, opts, rankKey)
	local building = Building.Normal(buildingPart, opts)
	--building.RefreshFunc = function()
	--	BuildingRank:Refresh(buildingPart, rankKey)
	--end
	
	task.spawn(function()
		task.wait(1)
		
		BuildingRank:Refresh(buildingPart, rankKey)
		
		EventManager:Listen(EventManager.Define.RefreshRank, function(param)
			if param.RankKey == rankKey then
				BuildingRank:Refresh(buildingPart, rankKey)
			end	
		end)
	end)
end

function BuildingRank:Refresh(buildingPart, rankKey)
	NetClient:Request("Rank", "GetRankList", { RankKey = rankKey }, function(rankList)
		UIList:LoadWithInfo(buildingPart, "UIRankItem", rankList)
	end)

	local playerInfoPart = Util:GetChildByName(buildingPart, "PlayerInfo")
	NetClient:Request("Record", "GetValue", { Key = rankKey }, function(result)
		local info = {
			Name = game.Players.LocalPlayer.Name,
			Value = result
		}

		UIInfo:SetInfo(playerInfoPart, info)
	end)
end

return BuildingRank
