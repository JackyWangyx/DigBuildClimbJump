local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIButton = require(game.ReplicatedStorage.ScriptAlias.UIButton)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)

local UIConfirm = {}

local DEFAULT_TITLE = "Confirm"
local DEFAULT_MESSAGE = "Are you sure?"
local DEFAULT_CONFIRM = "Confirm"
local DEFAULT_CANCEL = "Cancel"

function UIConfirm:Show(title, message, confirm, cancel, callback)
	local uiName = "UIConfirm"
	local uiPart = UIManager:ShowDialog(uiName, true)
	
	title = title or DEFAULT_TITLE
	UIInfo:SetValue(uiPart, "Title", title)
	
	message = message or DEFAULT_MESSAGE
	UIInfo:SetValue(uiPart, "Message", message)
	
	confirm = confirm or DEFAULT_CONFIRM
	UIInfo:SetValue(uiPart, "Confirm", confirm)
	
	cancel = cancel or DEFAULT_CANCEL
	UIInfo:SetValue(uiPart, "Cancel", cancel)
	
	if callback and typeof(callback) == "function" then
		local buttonConfirm = Util:GetChildByTypeAndName(uiPart, "GuiButton", "Button_Confirm")
		UIButton:Handle(buttonConfirm, function()
			callback(true)
			UIManager:HideDialog(uiPart, true)
		end)

		local buttonCancel = Util:GetChildByTypeAndName(uiPart, "GuiButton", "Button_Cancel")
		UIButton:Handle(buttonCancel, function()
			callback(false)
			UIManager:HideDialog(uiPart, true)
		end)
	end
end

return UIConfirm
