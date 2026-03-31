local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local ConfigManager = require(game.ReplicatedStorage.ScriptAlias.ConfigManager)
local AttributeUtil = require(game.ReplicatedStorage.ScriptAlias.AttributeUtil)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)
local UIListSelect = require(game.ReplicatedStorage.ScriptAlias.UIListSelect)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local UIConfirm = require(game.ReplicatedStorage.ScriptAlias.UIConfirm)
local PetUtil = require(game.ReplicatedStorage.ScriptAlias.PetUtil)
local TweenUtil = require(game.ReplicatedStorage.ScriptAlias.TweenUtil)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local IAPClient = require(game.ReplicatedStorage.ScriptAlias.IAPClient)
local PlayerManager = require(game.ReplicatedStorage.ScriptAlias.PlayerManager)
local TradeClient = require(game.ReplicatedStorage.ScriptAlias.TradeClient)
local TimeManager = require(game.ReplicatedStorage.ScriptAlias.TimerManager)

local Define = require(game.ReplicatedStorage.Define)

local UITradeInfo = {}

UITradeInfo.UIRoot = nil
UITradeInfo.FailFrame = nil
UITradeInfo.SuccessFrame = nil

UITradeInfo.Param = nil

function UITradeInfo:Init(root)
	UITradeInfo.UIRoot = root
	UITradeInfo.FailFrame = Util:GetChildByName(UITradeInfo.UIRoot, "FailFrame")
	UITradeInfo.SuccessFrame = Util:GetChildByName(UITradeInfo.UIRoot, "SuccessFrame")
end

function UITradeInfo:OnShow(param)
	UITradeInfo.Param = param
end

function UITradeInfo:OnHide()

end

function UITradeInfo:Refresh()
	local success = UITradeInfo.Param.Success
	local message = UITradeInfo.Param.Message
	UITradeInfo.SuccessFrame.Visible = success
	UITradeInfo.FailFrame.Visible = not success
	local info = {
		Message = UITradeInfo.Param.Message
	}
	
	if success then
		UIInfo:SetInfo(UITradeInfo.SuccessFrame, info)
	else
		UIInfo:SetInfo(UITradeInfo.FailFrame, info)
	end	
end

function UITradeInfo:Button_OK()
	UIManager:Hide("TradeInfo")
end

return UITradeInfo
