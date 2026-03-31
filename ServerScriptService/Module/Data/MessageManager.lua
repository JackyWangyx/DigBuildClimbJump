local MessagingService = game:GetService("MessagingService")

local MessageManager = {}

function MessageManager:Init()
	
end

local function Broadcast(messageKey, messageContent)
	local success, err = pcall(function()
		MessagingService:PublishAsync(messageKey, messageContent)
	end)
	if not success then
		warn("[Message] Failed to send message: ", err)
	end
end

local function Subscribe(messageKey, callback)
	local success, connection = pcall(function()
		return MessagingService:SubscribeAsync(messageKey, function(message)
			if callback then
				local messageContent =  message.Data
				callback(messageContent)
			end
		end)
	end)

	if not success then
		warn("[Message] Subscription failed")
	end
end

return MessageManager
