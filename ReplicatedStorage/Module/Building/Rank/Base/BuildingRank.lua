local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local Building = require(game.ReplicatedStorage.ScriptAlias.Building)

local Define = require(game.ReplicatedStorage.Define)

local BuildingRank = {}

function BuildingRank:Handle(buildingPart, opts, rankKey, onRankList)
	local building = Building.Normal(buildingPart, opts)

	--building.RefreshFunc = function()
	--	BuildingRank:Refresh(buildingPart, rankKey)
	--end
	
	task.spawn(function()
		task.wait(1)
		
		BuildingRank:Refresh(buildingPart, rankKey, onRankList)
		
		EventManager:Listen(EventManager.Define.RefreshRank, function(param)
			if param.RankKey == rankKey then
				BuildingRank:Refresh(buildingPart, rankKey, onRankList)
			end	
		end)
	end)
end

function BuildingRank:Refresh(buildingPart, rankKey, onRankList)
	NetClient:Request("Rank", "GetRankList", { RankKey = rankKey }, function(rankList)
		if not rankList then
			task.delay(10, function()
				BuildingRank:Refresh(buildingPart, rankKey, onRankList)
			end)
			
			return
		end
		
		for index, info in ipairs(rankList) do
			info.IsTop1 = false
			info.IsTop2 = false
			info.IsTop3 = false
			
			if index == 1 then
				info.IsTop1 = true
			end
			
			if index == 2 then
				info.IsTop2 = true
			end
			
			if index == 3 then
				info.IsTop3 = true
			end
		end
		
		UIList:LoadWithInfo(buildingPart, "UIRankItem", rankList)
		
		if onRankList then
			onRankList(rankList)
		end
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
