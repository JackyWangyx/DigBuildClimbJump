local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local BigNumber = require(game.ReplicatedStorage.ScriptAlias.BigNumber)
local RobloxUtil = require(game.ReplicatedStorage.ScriptAlias.RobloxUtil)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local ResourcesManager = require(game.ReplicatedStorage.ScriptAlias.ResourcesManager)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local NetServer = require(game.ServerScriptService.ScriptAlias.NetServer)
local PlayerProperty = require(game.ServerScriptService.ScriptAlias.PlayerProperty)
local IAPServer = require(game.ServerScriptService.ScriptAlias.IAPServer)

local IAPRequest = require(game.ServerScriptService.ScriptAlias.IAP)

local Define = require(game.ReplicatedStorage.Define)

local PlayerHud = {}

local PlayerCache = {}

local PrefabPath = "UIPage/UIHud"

------------------------------------------------------------------------------
-- Init / Add / Remove

function PlayerHud:Init()
	PlayerManager:HandleCharacterAddRemove(function(player, character)
		PlayerHud:OnPlayerAdded(player, character)
	end, function(player, character)
		PlayerHud:OnPlayerRemoved(player, character)
	end)

	--UpdatorManager:Heartbeat(function(deltaTime)
	--	PlayerHudIcon:Update(deltaTime)
	--end)
	
	EventManager:Listen(EventManager.Define.RefreshGamePass, function(player)
		PlayerHud:RefreshInfo(player)
	end)
end

function PlayerHud:OnPlayerAdded(player, character)
	local info = PlayerCache[player]
	if info then return end
	
	info = {}
	PlayerCache[player] = info
	
	PlayerHud:CreateHud(player, character)
	PlayerHud:RefreshInfo(player)
end

function PlayerHud:OnPlayerRemoved(player, character)
	local info = PlayerCache[player]
	if info then
		if info.UI then
			info.UI:Destroy()	
		end		
	end
	
	PlayerCache[player] = nil
end

------------------------------------------------------------------------------
-- Refresh Info
function PlayerHud:RefreshInfo(player)
	local info = PlayerCache[player]
	if not info then return end
	
	local hasVIP = IAPRequest:CheckHasGamePass(player, { ProductKey = "VIP" })
	local nickName = player.Name
	local showInfo = {
		NickName = nickName,
		HasVIP = hasVIP,
	}
	
	UIInfo:SetInfo(info.UI, showInfo)
end

------------------------------------------------------------------------------
-- Billboard

function PlayerHud:CreateHud(player, character)
	local info = PlayerCache[player]
	if not info then return end
	
	local prefab = ResourcesManager:Load(PrefabPath)
	if not prefab then return end
	
	local ui = prefab:Clone()
	local head = character:FindFirstChild("Head")
	ui.Adornee = head
	ui.Parent = head
	
	info.UI = ui
end

return PlayerHud
