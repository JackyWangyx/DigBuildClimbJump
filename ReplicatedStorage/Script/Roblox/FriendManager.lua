local RunService = game:GetService("RunService")
local SocialService = game:GetService("SocialService")
local HttpService = game:GetService("HttpService")

local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local TimeUtil = require(game.ReplicatedStorage.ScriptAlias.TimeUtil)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local Define = require(game.ReplicatedStorage.Define)

local FriendManager = {}

function FriendManager:Init()
	local isClient = RunService:IsClient()
	if isClient then
		
	else
		PlayerManager:HandlePlayerAddRemove(function(player)
			FriendManager:RefreshCache()
			EventManager:DispatchToAllClient(EventManager.Define.RefreshBuffFriendOnline)
		end, function(player)
			FriendManager:RefreshCache()
			EventManager:DispatchToAllClient(EventManager.Define.RefreshBuffFriendOnline)
		end)
	end
end

function FriendManager:GetFriendList()
	local success, pages = pcall(function()
		local player = game.Players.LocalPlayer
		return game.Players:GetFriendsAsync(player.UserId)
	end)

	if success then
		local result = {}
		while true do
			for _, friendInfo in ipairs(pages:GetCurrentPage()) do
				local playerInfo = {
					UserID = friendInfo.Id,
					IsOnline = friendInfo.IsOnline,
					Name = friendInfo.Username,
					DisplayName = friendInfo.DisplayName,
					--Icon = getPlayerThumbnail(friendInfo.UserId),
				}
				
				table.insert(result, playerInfo)
			end

			if pages.IsFinished then
				break
			end
			pages:AdvanceToNextPageAsync()
		end
		return result
	else
		return {}
	end
end

-- Client Only

function FriendManager:ClientInvite()
	local player = game.Players.LocalPlayer

	local function canSendGameInvite(sendingPlayer)
		local success, canSend = pcall(function()
			return game.SocialService:CanSendGameInviteAsync(sendingPlayer)
		end)
		return success and canSend
	end

	local canInvite = canSendGameInvite(player)
	if canInvite then
		local inviteOptions = Instance.new("ExperienceInviteOptions")
		inviteOptions.PromptMessage = Define.Message.InvitePrompt
		game.SocialService:PromptGameInvite(player, inviteOptions)
	end
end

-- Server Only

local FriendOnlineCache = {}

function FriendManager:GetFriendOnlineCount(player)
	local result = FriendOnlineCache[player]
	if not result then
		result = FriendManager:GetFriendOnlineCountImpl(player)
		FriendOnlineCache[player] = result
		EventManager:Dispatch(EventManager.Define.RefreshPlayerProperty, player)
	end
	
	return result
end

function FriendManager:RefreshCache()
	FriendOnlineCache = {}
end

function FriendManager:GetFriendOnlineCountImpl(player)
	local players = game.Players:GetPlayers()
	local count = 0
	for _, otherPlayer in pairs(players) do
		if player.UserId == otherPlayer.UserId then continue end
		if player:IsFriendsWith(otherPlayer.UserId) then
			count += 1
		end
	end
	return count
end

return FriendManager
