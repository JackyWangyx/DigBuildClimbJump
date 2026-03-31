local NetEvent = require(script.Parent.Parent.NetEvent)
local SignatureUtil = require(script.Parent.SignatureUtil)

local SignatureClient = {}

local SignatureKey = nil
local StartServerTimestamp = nil
local LocalTimestampOffset = nil

function SignatureClient:Init()
	SignatureUtil:Init()
	
	local initData = NetEvent.Signature:InvokeServer("GetInitData")

	SignatureKey = initData.Key
	StartServerTimestamp = initData.Timestamp
	LocalTimestampOffset = os.time() - StartServerTimestamp
end

function SignatureClient:GetKey()
	return SignatureKey
end

function SignatureClient:GetTimestamp()
	local timestamp = os.time() - LocalTimestampOffset
	return timestamp
end

return SignatureClient
