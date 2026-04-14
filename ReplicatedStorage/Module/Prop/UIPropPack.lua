local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIPropList = require(game.ReplicatedStorage.ScriptAlias.UIPropList)
local PetUtil = require(game.ReplicatedStorage.ScriptAlias.PetUtil)
local BigNumber = require(game.ReplicatedStorage.ScriptAlias.BigNumber)

local Define = require(game.ReplicatedStorage.Define)

local UIPropPack = {}

UIPropPack.UIRoot = nil
UIPropPack.UIPropFrame = nil

function UIPropPack:Init(root)
	UIPropPack.UIRoot = root
	UIPropPack.UIPropFrame = Util:GetChildByName(root, "PropFrame")
	UIPropList:Init(UIPropPack.UIPropFrame)
end

function UIPropPack:OnShow(param)

end

function UIPropPack:OnHide()

end

function UIPropPack:Refresh()
	UIPropList:Refresh()
end

-- Other Page

function UIPropPack:Button_PetPack()
	UIManager:ShowAndHideOther("PetPack")
end

return UIPropPack
