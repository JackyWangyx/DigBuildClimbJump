local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)

local PlayerPrefs = require(game.ServerScriptService.ScriptAlias.PlayerPrefs)
local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)

local PropServerHandler = {}

local PlayerCahce = {}

function PropServerHandler:Init()
	PlayerManager:HandleCharacterAddRemove(function(player, character)
		PropServerHandler:ClearPlayerCache(player)
	end, function(player, character)
		PropServerHandler:ClearPlayerCache(player)
	end)
	
	local connection = UpdatorManager:Heartbeat(function(deltaTime)
		PropServerHandler:Update(deltaTime)
	end)
	
	game:BindToClose(function()
		connection:Disconnect()
	end)
end

function PropServerHandler:GetPlayerCache(player)
	local playerCahce = PlayerCahce[player]
	if not playerCahce then
		local runtimeInfoList = NetServer:RequireModule("Prop"):GetRuntimeList(player)
		playerCahce = {}
		for _, info in ipairs(runtimeInfoList) do
			local runtimePropInfo = {
				ID = info.ID,
				Info = info,
				Data = ConfigManager:GetData("Prop", info.ID)
			}
			
			table.insert(playerCahce, runtimePropInfo)
		end
		
		PlayerCahce[player] = playerCahce
	end
	
	return playerCahce
end

function PropServerHandler:ClearPlayerCache(player)
	PlayerCahce[player] = nil
end

function PropServerHandler:Update(deltaTime)
	local playerList = game.Players:GetPlayers()
	for _, player in ipairs(playerList) do
		if not PlayerPrefs:GetPlayerSaveInfoState(player) then
			continue
		end
		
		local playerCache = PropServerHandler:GetPlayerCache(player)
		if playerCache == nil or #playerCache == 0 then continue end
		for _, runtimePropInfo in ipairs(playerCache) do
			runtimePropInfo.Info.Duration -= deltaTime
			if runtimePropInfo.Info.Duration <= 0 then
				local result = NetServer:RequireModule("Prop"):Stop(player, {
					ID = runtimePropInfo.ID
				})
				
				--print(playerCache, runtimePropInfo.ID, result)
				if result then
					PropServerHandler:ClearPlayerCache(player)
					break
				end
			end
		end
	end
end

return PropServerHandler
