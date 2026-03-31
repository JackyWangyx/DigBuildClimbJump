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

local UIRedeemCode = {}

UIRedeemCode.UIRoot = nil
UIRedeemCode.TextInput = nil

function UIRedeemCode:Init(root)
	UIRedeemCode.UIRoot = root
	UIRedeemCode.TextInput = Util:GetChildByName(UIRedeemCode.UIRoot, "TextInput_RedeemCode")
	UIRedeemCode:ClearInput()
end

function UIRedeemCode:OnShow(param)
	UIRedeemCode:ClearInput()
end

function UIRedeemCode:OnHide()
	
end

function UIRedeemCode:Refresh()
	
end

function UIRedeemCode:ClearInput()
	UIRedeemCode.TextInput.Text = ""
end

function UIRedeemCode:Button_Redeem()
	local redeemCode = UIRedeemCode.TextInput.Text
	if Util:IsStrEmpty(redeemCode) then
		return
	end
	
	NetClient:Request("Redeem", "GetReward", { RedeemCode = redeemCode },  function(result)
		if result.Success then
			local rewardList = result.RewardList
			for _, data in ipairs(rewardList) do
				UIManager:ShowMessageWithIcon(data.Icon, "Got "..data.Description)
				task.wait()
			end
		else
			UIManager:ShowMessage(result.Message)
		end
		UIRedeemCode:ClearInput()
	end)
end

return UIRedeemCode
