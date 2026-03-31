local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local AnalyticsManager = require(game.ReplicatedStorage.ScriptAlias.AnalyticsManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)

local Define = require(game.ReplicatedStorage.Define)

local Prop = {}

local SaveInfoDemo = {
	RuntimeList = {
		[1] = {
			InstanceID = 0,
			ID = 1,
			StartTime = 0,
			Duration = 0,
			},
		[2] = {
			InstanceID = 0,
			ID = 1,
			StartTime = 0,
			Duration = 0,
		},
	},
	PackageList = {
		[1] = {
			ID = 1,
			Count = 1,
		}
	}
}

function LoadInfo(player)
	local saveInfo = PlayerPrefs:GetModule(player, "Prop")
	return saveInfo
end

function Prop:GetPackageList(player)
	local saveInfo = LoadInfo(player)
	if not saveInfo.PackageList then
		saveInfo.PackageList = {}
	end
	return saveInfo.PackageList
end

function Prop:GetRuntimeList(player)
	local saveInfo = LoadInfo(player)
	if not saveInfo.RuntimeList then
		saveInfo.RuntimeList = {}
	end
	return saveInfo.RuntimeList
end

function Prop:GetRuntimePropertyList(player)
	local runtimePropList = Prop:GetRuntimeList(player)
	local result = {}
	for _, propInfo in ipairs(runtimePropList) do
		local data = ConfigManager:GetData("Prop", propInfo.ID)
		table.insert(result, data)
	end
	
	return result
end

function Prop:Buy(player, param)
	local id = param.ID
	local count = param.Count
	local data = ConfigManager:GetData("Prop", id)
	if not count then
		count = data.BuyCount
	end
	local packageList = Prop:GetPackageList(player)
	local info = Util:ListFind(packageList, function(tempInfo) 
		return tempInfo.ID == id
	end)
	
	if info then
		info.Count += count
	else
		info = {
			ID = id,
			Count = count,
		}
		
		table.insert(packageList, info)
	end
	
	AnalyticsManager:Event(player, AnalyticsManager.Define.BuyProp, id, count)
	
	return true
end

function Prop:Stop(player, param)
	local id = param.ID
	local runtimeList = Prop:GetRuntimeList(player)
	local existInfoIndex = -1
	for i, info in ipairs(runtimeList) do
		if info.ID == id then
			existInfoIndex = i
			break
		end
	end
	
	if existInfoIndex > 0 then
		table.remove(runtimeList, existInfoIndex)
		EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
		return true
	end
	
	return false
end

function Prop:Use(player, param)
	local packageList = Prop:GetPackageList(player)
	local propServerHandler = require(game.ServerScriptService.ScriptAlias.PropServerHandler)
	
	local id = param.ID
	local existInPackage = false
	local existPackageInfo = nil
	for _, info in ipairs(packageList) do
		if info.ID == id and info.Count >= 1 then
			existPackageInfo = info
			existInPackage = true
			break
		end
	end
	
	if not existInPackage or existPackageInfo.Count < 1 then
		return {
			Success = false,
			Message = Define.Message.PropNotExist
		}
	end
	
	local runtimeList = Prop:GetRuntimeList(player)
	local existInRuntime = false
	for _, info in ipairs(runtimeList) do
		if info.ID == id then
			existInRuntime = true
			break
		end
	end
	
	if existInRuntime then
		for _, info in ipairs(runtimeList) do
			if info.ID == id then
				existPackageInfo.Count -= 1
				local data = ConfigManager:GetData("Prop", id)
				info.Duration += data.Duration
				propServerHandler:ClearPlayerCache(player)
				break
			end
		end
		
		AnalyticsManager:Event(player, AnalyticsManager.Define.UseProp, id, 1)
		EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
		return {
			Success = true,
			Message = "Add Duration"
		}
	else
		existPackageInfo.Count -= 1
		local data = ConfigManager:GetData("Prop", id)
		local usePropInfo = {
			ID = id,
			Duration = data.Duration
		}

		table.insert(runtimeList, usePropInfo)
		propServerHandler:ClearPlayerCache(player)
		
		AnalyticsManager:Event(player, AnalyticsManager.Define.UseProp, id, 1)
		EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
		return {
			Success = true,
			Message = "Use New",
		}
	end
end

return Prop
