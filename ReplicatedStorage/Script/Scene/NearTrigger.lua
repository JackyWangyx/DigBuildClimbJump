local UpdatorManager = require(game.ReplicatedStorage.ScriptAlias.UpdatorManager)

local NearTrigger = {}

local Cache = {}
local CacheCount = 0

UpdatorManager:Heartbeat(function(deltaTime)
	NearTrigger:Update(deltaTime)
end)

function NearTrigger:Register(part, distance, interval, func)
	if Cache[part] then return end
	local info = {
		Part = part,
		Distance = distance,
		Func = func,
		Triggerd = false,
		Interval = interval,
		LastTriggerTime = 0,
	}
	
	Cache[part] = info
	CacheCount += 1
end

function NearTrigger:DeRegister(part)
	if not Cache[part] then return end
	Cache[part] = nil
	CacheCount -= 1
end

function NearTrigger:Update(deltaTime)
	if CacheCount == 0 then return end
	local player = game.Players.LocalPlayer
	if not player.Character then return end
	local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end
	
	local currentTime = os.time()
	for part, info in pairs(Cache) do
		local c1 = (rootPart.Position - part.Position).Magnitude < info.Distance
		local c2 = currentTime - info.LastTriggerTime >= info.Interval
		if c1 and c2 then
			if not info.Triggerd then
				info.Triggerd = true
				info.Func()
				info.LastTriggerTime = currentTime
			else
				info.Triggerd = false
			end
		end
	end
end

return NearTrigger
