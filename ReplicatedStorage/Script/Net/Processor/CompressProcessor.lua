local NetCompressUtil = require(script.Parent.Parent.Compress.NetCompressUtil)

local CompressProcessor = {}

function CompressProcessor:Init()
	NetCompressUtil:Init()
end 

function CompressProcessor:Send(player, dataPack)
	local result = NetCompressUtil:Compress(dataPack)
	return result
end

function CompressProcessor:Receive(player, dataPack)
	local result = NetCompressUtil:Decompress(dataPack)
	return result
end

return CompressProcessor
