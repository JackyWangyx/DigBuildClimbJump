local ClientBroadcastModuleDemo = {}

-- Client process broadcast
function ClientBroadcastModuleDemo:OnBroadcast(player, param)
	local message = param.Message
	print(message)
end

return ClientBroadcastModuleDemo
