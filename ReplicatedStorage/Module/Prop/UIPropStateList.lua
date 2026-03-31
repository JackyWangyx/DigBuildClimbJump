local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local TimeUtil = require(game.ReplicatedStorage.ScriptAlias.TimeUtil)

local UIPropStateList = {}

UIPropStateList.Root = nil
UIPropStateList.InfoList = {}
UIPropStateList.ItemList = {}

local REFRESH_INTERVAL = 1

function UIPropStateList:Init(root)
	UIPropStateList.Root = root
	local accumulatedTime = 0

	UpdatorManager:Heartbeat(function(dt)
		accumulatedTime += dt
		if accumulatedTime >= REFRESH_INTERVAL then
			accumulatedTime = accumulatedTime - REFRESH_INTERVAL
			UIPropStateList:UpdateCountdown()
		end
	end)

	UIPropStateList:RefreshList()
	EventManager:Listen(EventManager.Define.RefreshProp, function()
		UIPropStateList:RefreshList()
	end)
end

function UIPropStateList:RefreshList()
	NetClient:Request("Prop", "GetRuntimeList", function(result)
		UIPropStateList.InfoList = result
		UIPropStateList.ItemList = UIList:LoadWithInfoData(UIPropStateList.Root,"UIPropStateItem", UIPropStateList.InfoList, "Prop")
	end)
end

function UIPropStateList:UpdateCountdown()
	if not UIPropStateList.InfoList or not UIPropStateList.ItemList then return end
	local hasFinish = false
	for _, info in ipairs(UIPropStateList.InfoList) do
		if info.Duration > 0 then
			info.Duration -= REFRESH_INTERVAL
			if info.Duration < 0 then
				info.Duration = 0
				hasFinish = true
			end
			
			info.Time = TimeUtil:FormatMsToMMSS(math.round(info.Duration * 1000))
		end
	end

	for i, item in ipairs(UIPropStateList.ItemList) do
		local info = UIPropStateList.InfoList[i]
		if item then
			UIInfo:SetInfo(item, info)
		end
	end
	
	if hasFinish then
		UIPropStateList:RefreshList()
	end
end

return UIPropStateList
