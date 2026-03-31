local GuiService = game:GetService("GuiService")

local NetClient = require(game.ReplicatedStorage.ScriptAlias.NetClient)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIList = require(game.ReplicatedStorage.ScriptAlias.UIList)

local UIQuitGame = {}

UIQuitGame.UIRoot = nil
UIQuitGame.ItemList = nil

function UIQuitGame:Init(root)
	UIQuitGame.UIRoot = root
	
	GuiService.MenuOpened:Connect(function()
		UIManager:ShowAndHideOther("QuitGame")
	end)
end

function UIQuitGame:OnShow()

end

function UIQuitGame:OnHide()

end

function UIQuitGame:Refresh()
	NetClient:RequestQueue({
		{ Module = "Sign", Action = "GetNextDailyReward", Param = { Key = "SignDaily7" } },
		{ Module = "Sign", Action = "GetNextDailyReward", Param = { Key = "SignDaily15" } }
	}, function(result)
		local dataList1 = result[1]
		local dataList2 = result[2]
		local infoList = Util:TableMerge(dataList1, dataList2)
		UIQuitGame.ItemList = UIList:LoadWithInfo(UIQuitGame.UIRoot, "UINextDailyRewardItem", infoList)
	end)
end

return UIQuitGame