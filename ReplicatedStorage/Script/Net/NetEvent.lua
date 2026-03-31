local RunService = game:GetService("RunService")

local NetEvent = {}

NetEvent.Connect = nil
NetEvent.Broadcast = nil
NetEvent.Request = nil
NetEvent.RequestQueue = nil
NetEvent.Signature = nil

function NetEvent:Init()
	NetEvent.Connect = NetEvent:GetOrCreate("RemoteEvent", "Net_Connect")
	NetEvent.Broadcast = NetEvent:GetOrCreate("RemoteEvent", "Net_Broadcast")
	NetEvent.Request = NetEvent:GetOrCreate("RemoteFunction", "Net_Request")
	NetEvent.RequestQueue = NetEvent:GetOrCreate("RemoteFunction", "Net_RequestQueue")
	NetEvent.Signature = NetEvent:GetOrCreate("RemoteFunction", "Net_Signature")
end

function NetEvent:GetOrCreate(remoteType, remoteName)
	local folder = NetEvent:GetReplicatedFolder("RuntimeOnly_Event")
	local remote = folder:FindFirstChild(remoteName)
	if RunService:IsServer() then
		if not remote then
			remote = Instance.new(remoteType)
			remote.Name = remoteName
			remote.Parent = folder
		end
		return remote
	else
		return remote
	end
end

function NetEvent:GetReplicatedFolder(folderName)
	local folder = game.ReplicatedStorage:FindFirstChild(folderName)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = folderName
		folder.Parent = game.ReplicatedStorage
	end
	return folder
end

return NetEvent
