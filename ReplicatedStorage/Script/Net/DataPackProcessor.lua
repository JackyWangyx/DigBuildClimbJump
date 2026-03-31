local RunService = game:GetService("RunService")

local SignatureProcessor = require(script.Parent.Processor.SignatureProcessor)
local CompressProcessor = require(script.Parent.Processor.CompressProcessor)

local DataPackProcessor = {}

local ProcessorList = {}

function DataPackProcessor:Init()
	--DataPackProcessor:Register(SignatureProcessor)
	DataPackProcessor:Register(CompressProcessor)
end

function DataPackProcessor:Register(processor)
	processor:Init()
	local count = #ProcessorList
	ProcessorList[count + 1] = processor
end

function DataPackProcessor:Send(player, dataPack)
	if RunService:IsClient() then
		dataPack = player
		player = game.Players.LocalPlayer
	end
	
	for i = 1, #ProcessorList do
		local processor = ProcessorList[i]
		dataPack = processor:Send(player, dataPack)
	end
	
	return dataPack
end

function DataPackProcessor:Receive(player, dataPack)
	if RunService:IsClient() then
		dataPack = player
		player = game.Players.LocalPlayer
	end
	
	for i = #ProcessorList, 1, -1 do
		local processor = ProcessorList[i]
		dataPack = processor:Receive(player, dataPack)
	end

	return dataPack
end

return DataPackProcessor
