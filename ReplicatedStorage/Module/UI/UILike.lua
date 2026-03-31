local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)
local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local RobloxUtil = require(game.ReplicatedStorage.ScriptAlias.RobloxUtil)

local Define = require(game.ReplicatedStorage.Define)

local UILike = {}

UILike.UIRoot = nil

function UILike:Init(root)
	UILike.UIRoot = root
end

function UILike:OnShow()

end

function UILike:OnHide()

end

function UILike:Refresh()
	
end

function UILike:Button_Claim()
	local isInGroup = PlayerManager:IsInOfficalGroup(game.Players.LocalPlayer)
	if not isInGroup then 
		UIManager:ShowMessage(Define.Message.NotInGroup)
		return
	end
	
	UIManager:Hide("Like")
	
	NetClient:Request("IAP", "BuyPackage", { ID = Define.Game.LikePackageID })
	NetClient:Request("Reward", "GetLikePack", function(result)
		if result.Success then
			local rewardList = result.RewardList
			for _, data in pairs(rewardList) do
				if data.Icon then
					UIManager:ShowMessageWithIcon(data.Icon, "Got "..data.Description)
					task.wait()
				end
			end
		end
	end)
	
	EventManager:Dispatch(EventManager.Define.RefreshOfficalGroup)
end

function UILike:Button_Vote()
	RobloxUtil:OpenGamePage()
end

function UILike:Button_Favorite()
	RobloxUtil:OpenFavorite()
end

function UILike:Button_Group()
	RobloxUtil:OpenOfficalGroup()
end

return UILike