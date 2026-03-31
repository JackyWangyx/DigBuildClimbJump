local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)

local UIBuffInfo = {}

UIBuffInfo.Root = nil
UIBuffInfo.BuffFrame = nil

UIBuffInfo.UIBuffFriendOnline = require(game.ReplicatedStorage.ScriptAlias.UIBuffFriendOnline)
UIBuffInfo.UIBuffPremium = require(game.ReplicatedStorage.ScriptAlias.UIBuffPremium)
UIBuffInfo.UIBuffOnline = require(game.ReplicatedStorage.ScriptAlias.UIBuffOnline)

function UIBuffInfo:Init(root)
	UIBuffInfo.Root = root
	UIBuffInfo.UIBuffFrame = Util:GetChildByName(root, "UIBuffFrame")
	UIBuffInfo.UIBuffFriendOnline:Init(Util:GetChildByName(UIBuffInfo.UIBuffFrame, "BuffFriendOnline"))
	UIBuffInfo.UIBuffPremium:Init(Util:GetChildByName(UIBuffInfo.UIBuffFrame, "BuffPremium"))
	UIBuffInfo.UIBuffOnline:Init(Util:GetChildByName(UIBuffInfo.UIBuffFrame,"BuffOnline"))
end

function UIBuffInfo:Refresh()
	UIBuffInfo.UIBuffFriendOnline:Refresh()
	UIBuffInfo.UIBuffPremium:Refresh()
	UIBuffInfo.UIBuffOnline:Refresh()
end

return UIBuffInfo
