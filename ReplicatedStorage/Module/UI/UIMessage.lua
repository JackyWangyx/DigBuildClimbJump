local UIButtonOpen = require(game.ReplicatedStorage.ScriptAlias.UIButtonOpen)
local Util = require(game.ReplicatedStorage.ScriptAlias.Util)
local UIManager = require(game.ReplicatedStorage.ScriptAlias.UIManager)
local UIInfo = require(game.ReplicatedStorage.ScriptAlias.UIInfo)
local UTween = require(game.ReplicatedStorage.ScriptAlias.UTween)

local UIMessage = {}

UIMessage.UIRoot = nil
UIMessage.ScrollingFrame = nil

UIMessage.MessageShowTime = 1
UIMessage.MessageList = {}

function UIMessage:Init(root)
	UIMessage.UIRoot = root	
	UIMessage.ScrollingFrame = Util:GetChildByName(UIMessage.UIRoot, "ScrollingFrame")
	
	task.spawn(UIMessage.AutoClearMessage)
end

function UIMessage:OnShow()

end

function UIMessage:OnHide()

end

function UIMessage:ShowMessageWithIcon(icon, message)
	local messageItemPrefab = Util:LoadPrefab("UIItem/UIMessageItem")
	local messageItem = messageItemPrefab:Clone()
	messageItem.Parent = UIMessage.ScrollingFrame

	local showInfo = {
		Icon = icon,
		Message = message,
	}

	UIInfo:SetInfo(messageItem, showInfo)
	
	
	local iconPart = Util:GetChildByName(messageItem, "Image_Icon")
	if iconPart then
		if icon == nil then
			iconPart.Visible = false
		else
			iconPart.Visible = true
		end
	end

	local messageInfo = {
		Item = messageItem,
		Time = os.time()
	}
	
	local mainFrame = messageItem.MainFrame
	UTween:GuiScaleValue(mainFrame, Vector2.new(0, 0), Vector2.new(1,1), 0.15)
	table.insert(UIMessage.MessageList, messageInfo)
end

function UIMessage:ShowMessage(message)
	UIMessage:ShowMessageWithIcon(nil, message)
end

function UIMessage:AutoClearMessage()
	while true do
		task.wait(1)
		local currentTime = os.time()
		for i = #UIMessage.MessageList, 1, -1 do
			local messageInfo = UIMessage.MessageList[i]
			if currentTime - messageInfo.Time > UIMessage.MessageShowTime then
				UTween:GuiGroupTransparency(messageInfo.Item, 0, 1, 0.15)
					:SetOnComplete(function()
						messageInfo.Item:Destroy()
					end)
				
				table.remove(UIMessage.MessageList, i)
			end
		end
	end
end

return UIMessage