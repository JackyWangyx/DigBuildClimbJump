local RunService = game:GetService("RunService")

local SignatureUtil = require(script.Parent.Parent.Signature.SignatureUtil)

local SignatureProcessor = {}

local IsClient = nil
local IsServer = nil
local Client = nil
local Server = nil

function SignatureProcessor:Init()
	IsClient = RunService:IsClient()
	IsServer = not IsClient
	if IsClient then
		Client = require(script.Parent.Parent.Signature.SignatureClient)
		Client:Init()
	else
		Server = require(game.ServerScriptService.Net.Signature.SignatureServer)
		Server:Init()
	end
end 

function SignatureProcessor:GetKey(player)
	local key = nil
	if IsClient then
		key = Client:GetKey()	
	else
		key = Server:GetKey(player)	
	end
	return key
end

function SignatureProcessor:GetTimestamp()
	local timestamp = nil
	if IsClient then
		timestamp = Client:GetTimestamp()	
	else
		timestamp = os.time()
	end
	return timestamp
end

function SignatureProcessor:Send(player, dataPack)
	if IsClient then
		if type(dataPack) ~= "table" then
			return dataPack
		end

		local key = SignatureProcessor:GetKey(player)
		local signature = SignatureUtil:Sign(dataPack, key)
		local timestamp = SignatureProcessor:GetTimestamp()

		dataPack.Signature = signature
		dataPack.Timestamp = timestamp

		return dataPack
	else
		return dataPack
	end
end

function SignatureProcessor:Receive(player, dataPack)
	if IsServer then
		if type(dataPack) ~= "table" then
			return dataPack
		end

		local key = SignatureProcessor:GetKey(player)
		local clientSignature = dataPack.Signature
		local clientTimestamp = dataPack.Timestamp
		
		-- Check Timestamp
		if clientTimestamp then
			local serverTimestamp = os.time()
			
			local timeDiff = math.abs(clientTimestamp - serverTimestamp)
			if timeDiff > 3 then
				-- TODO
				warn(player, clientTimestamp, serverTimestamp, dataPack)
				
				return dataPack
			end
		end
		
		-- Check Signature
		if clientSignature then
			dataPack.Signature = nil
			dataPack.Timestamp = nil
			
			local signature = SignatureUtil:Sign(dataPack, key)
			
			if signature ~= clientSignature then
				-- TODO		
				warn(player, clientSignature, signature, key, dataPack)
				
				return dataPack
			end
		end
		
		return dataPack
	else
		return dataPack
	end
end

return SignatureProcessor
