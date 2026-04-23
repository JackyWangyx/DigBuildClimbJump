local MemoryStoreService = game:GetService("MemoryStoreService")
local RunService = game:GetService("RunService")

local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)
local VersionUtil = require(game.ReplicatedStorage.ScriptAlias.VersionUtil)

local Define = require(game.ReplicatedStorage.Define)

local MasterServer = {}

MasterServer.IsMaster = false

local MASTER_KEY = "CurrentMasterServer"
local SERVER_ID = nil
local HEARTBEAT_INTERVAL = 45
local LOCK_TTL = 120

local LastHeartbeat = 0

local MasterHashMap = MemoryStoreService:GetHashMap("MasterServer")

function MasterServer:Init()
	SERVER_ID = game.JobId
	if RunService:IsStudio() then
		warn(SERVER_ID)
		SERVER_ID = "Studio"
	end
	
	local result = MasterServer:TryBecomeMaster()
	
	if not result then
		task.spawn(function()
			-- 非 Master 服务器定期检查（可选：每 30-60 秒尝试一次抢占）
			while not MasterServer.IsMaster do
				task.wait(30)
				result = MasterServer:TryBecomeMaster()
				if result then
					break
				end
			end
		end)
	end
end

function MasterServer:TryBecomeMaster()
	local success, result = pcall(function()
		return MasterHashMap:UpdateAsync(MASTER_KEY, function(oldData)
			local now = os.time()
			local currentVersion = VersionUtil:GetVersion()
	
			local c1 = not oldData	-- 当前无有效主机
			local c2 = oldData and oldData.Timestamp or 0 > LOCK_TTL -- 当前主机超时
			local c3 = oldData and VersionUtil:Compare(currentVersion, oldData.Version)  -- 当前主机版本过时
			if c1 or c2 or c3 then
				return {
					ServerID = SERVER_ID,
					Timestamp = now,
					Version = currentVersion
				}
			else
				return nil  -- 已有有效 Master，不抢占
			end
		end, LOCK_TTL)  -- 第三个参数是这个记录的 TTL
	end)

	if success and result then
		LastHeartbeat = os.time()
		MasterServer.IsMaster = true
		
		UpdatorManager:Heartbeat(function()
			print("Heart")
			MasterServer:Update()
		end, HEARTBEAT_INTERVAL)
		
		print("[Master Server]", "Become Master : ", SERVER_ID)		
		return true
	end
	
	return false
end

function MasterServer:Update()
	local success = pcall(function()
		MasterHashMap:SetAsync(MASTER_KEY, {
			ServerID = SERVER_ID,
			Timestamp = os.time(),
			Version = Define.Version
		}, LOCK_TTL)
	end)

	if not success then
		MasterServer.IsMaster = false
	end
	
	LastHeartbeat = os.time()
end

return MasterServer
