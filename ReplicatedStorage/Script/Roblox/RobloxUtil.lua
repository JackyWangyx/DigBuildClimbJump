local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local Define = require(game.ReplicatedStorage.Define)

local RobloxUtil = {}

-- Core UI

function RobloxUtil:DisableResetButton()
	pcall(function()
		local StarterGui = game.StarterGui
		StarterGui:SetCore("ResetButtonCallback", false)
	end)
end

-- Premium

function RobloxUtil:IsPremium(player)
	if not player then return false end
	local result = player.MembershipType == Enum.MembershipType.Premium
	return result
end

function RobloxUtil:OpenPremium()
	local player = game.Players.LocalPlayer
	local isPremium = RobloxUtil:IsPremium(player)
	if isPremium then return end
	MarketplaceService:PromptPremiumPurchase(player)
end

if RunService:IsClient() then
	MarketplaceService.PromptPremiumPurchaseFinished:Connect(function()
		task.delay(1, function()
			EventManager:Dispatch(EventManager.Define.RefreshPremium)
		end)
	end)
end

-- Group

function RobloxUtil:CheckCanViewSocialLinks(player)
	if player.AccountAge and player.AccountAge >= 365 * 13 then
		return true
	end
	return false
end

function RobloxUtil:GetOfficlGroupUrl()
	local result = "https://www.roblox.com/groups/" .. Define.Game.OfficalGroupID .. "/group"
	return result
end

function RobloxUtil:OpenOfficalGroup()
	local url = RobloxUtil:GetOfficlGroupUrl()
	game:GetService("GuiService"):OpenBrowserWindow(url)
end

-- Game Page

function RobloxUtil:GetGamePageUrl()
	local result = "https://www.roblox.com/games/" .. Define.Game.GamePlaceID
	return result
end

function RobloxUtil:OpenGamePage()	
	local url = RobloxUtil:GetGamePageUrl()
	game:GetService("GuiService"):OpenBrowserWindow(url)
end

-- Favorite

function RobloxUtil:OpenFavorite()
	local AES = game:GetService("AvatarEditorService")
	AES:PromptSetFavorite(Define.Game.GamePlaceID, Enum.AvatarItemType.Asset, true)
end

function RobloxUtil:CheckFavorite()
	local AES = game:GetService("AvatarEditorService")
	AES:PromptAllowInventoryReadAccess()
	local favorite = AES:GetFavorite(Define.Game.GamePlaceID, Enum.AvatarItemType.Asset)
	return favorite
end

-------------------------------------------------------------------------------------------
-- Server Only
-------------------------------------------------------------------------------------------

function RobloxUtil:GetRoomID()
	return game.JobId or game.PrivateServerId or "NULL"
end

-- https://create.roblox.com/docs/zh-cn/reference/engine/classes/PolicyService#GetPolicyInfoForPlayerAsync
function RobloxUtil:GetPlayerPolicy(player)
	local policyService = game:GetService("PolicyService")
	local success, pollicy = pcall(function()
		return policyService:GetPolicyInfoForPlayerAsync(player)
	end)

	if success and pollicy then
		--print(pollicy)
		return pollicy
	else
		return nil
	end
end

return RobloxUtil
