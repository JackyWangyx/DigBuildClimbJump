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
local EventManager = require(game.ReplicatedStorage.ScriptAlias.EventManager)

local Define = require(game.ReplicatedStorage.Define)

local UILuckyWheel = {}

UILuckyWheel.UIRoot = nil
UILuckyWheel.ItemList = nil
UILuckyWheel.ScrollingFrame = nil

UILuckyWheel.IsWorking = false

function UILuckyWheel:Init(root)
	UILuckyWheel.UIRoot = root

	local childList= UILuckyWheel.UIRoot:GetDescendants()
	UILuckyWheel.ScrollingFrame = Util:GetChildByName(root, "ScrollingFrame", true, childList)
end

function UILuckyWheel:OnShow(param)
	UILuckyWheel.IsWorking = false
end

function UILuckyWheel:OnHide()
	UILuckyWheel.IsWorking = false
end

function UILuckyWheel:Refresh()
	UILuckyWheel:RefreshItemList()
end

function UILuckyWheel:RefreshItemList()
	NetClient:Request("LuckyWheel", "GetList", function(result)
		UILuckyWheel.ItemList = UIList:LoadWithInfo(UILuckyWheel.UIRoot, nil, result.RewardList)
		local uiInfo = {
			RemainCount = "x"..tostring(result.RemainCount),
		}
		
		UIInfo:SetInfo(UILuckyWheel.UIRoot, uiInfo)
	end)
end

function UILuckyWheel:Button_Spin1()
	IAPClient:Purchase("LuckyWheelX1", function(result)
		UILuckyWheel:Refresh()
		EventManager:Dispatch(EventManager.Define.RefreshLuckyWheel)
	end)
end

function UILuckyWheel:Button_Spin10()
	IAPClient:Purchase("LuckyWheelX10", function(result)
		UILuckyWheel:Refresh()
		EventManager:Dispatch(EventManager.Define.RefreshLuckyWheel)
	end)
end

function UILuckyWheel:Button_Spin100()
	IAPClient:Purchase("LuckyWheelX100", function(result)
		UILuckyWheel:Refresh()
		EventManager:Dispatch(EventManager.Define.RefreshLuckyWheel)
	end)
end

function UILuckyWheel:Button_Spin()
	UILuckyWheel:Spin()
end

function UILuckyWheel:Spin()
	if UILuckyWheel.IsWorking then return end
	UILuckyWheel.IsWorking = true
	NetClient:Request("LuckyWheel", "Spin", function(result)
		if result.Success then
			local spinIndex = result.RewardIndex
			TweenUtil:Spin(UILuckyWheel.ScrollingFrame, 8, spinIndex, function()
				if not UILuckyWheel.IsWorking then return end
				NetClient:Request("LuckyWheel", "GetReward", { RewardIndex = spinIndex }, function(success)
					if success then
						local data = result.RewardData
						UIManager:ShowMessageWithIcon(data.Icon, "Got "..data.Description2)
						UILuckyWheel:Refresh()
						EventManager:Dispatch(EventManager.Define.RefreshLuckyWheel)
					end
					UILuckyWheel.IsWorking = false
				end)	
			end)
			
		else	
			UIManager:ShowMessage(result.Message)
			UILuckyWheel.IsWorking = false
		end
	end)
end

return UILuckyWheel
