local ServerRequestModuleDemo = {}

-- Server process request
function ServerRequestModuleDemo:OnRequest(player, param)
	if param ~= nil then
		local message = param.Message
		print(message)
	else
		print("Request without message")
	end
	
	return true
end

return ServerRequestModuleDemo
